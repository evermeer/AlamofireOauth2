//
//  CROAuth2Client.swift
//  CROAuth2Client
//
//  Created by Clement Rousselle on 8/26/14.
//  Copyright (c) 2014 Clement Rousselle. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

let kCROAuth2AccessTokenService: CFStringRef = "CROAuth2AccessToken"
let kCROAuth2RefreshTokenService: CFStringRef = "CROAuth2RefreshToken"
let kCROAuth2ExpiresInService: CFStringRef = "CROAuth2ExpiresIn"
let kCROAuth2CreationDateService: CFStringRef = "CROAuth2CreationDate"

class CROAuth2Client : NSObject {
    
    var baseURL:String
    var sourceViewController:UIViewController?
    
    private func postRequestHandler(jsonResponse:AnyObject?, error:NSError?, token:((accessToken:String?) -> Void)) -> Void {  
        if let err = error {
            println(error)
            token(accessToken: nil)
        } else {
            let accessToken:String = self.retrieveAccessTokenFromJSONResponse(jsonResponse!)
            token(accessToken: accessToken)
        }
    }
    
    // MARK: - 
    
    class func baseUrl() -> String {
        return CRCredentialsHelper.sharedInstance().baseURL()
    }
    
    class func authorizeURL() -> String {
        return CRCredentialsHelper.sharedInstance().authorizeURL()
    }
    
    class func clientID() -> String {
        return CRCredentialsHelper.sharedInstance().clientID()
    }

    class func clientSecret() -> String {
        return CRCredentialsHelper.sharedInstance().clientSecret()
    }
    
    class func redirectURI() -> String {
        return CRCredentialsHelper.sharedInstance().redirectURI()
    }
    
    class func tokenURL() -> String {
        return CRCredentialsHelper.sharedInstance().tokenURL()
    }
    
    // MARK: - Public Methods

    class func clientWithPresentingController(controller:UIViewController) -> CROAuth2Client {

        var client:CROAuth2Client = CROAuth2Client(baseURL:CROAuth2Client.baseUrl())
        client.sourceViewController = controller
        
        return client
        
    }
    
    init(baseURL:String) {
        self.baseURL = baseURL
    }
    
    func retrieveAuthToken(token:((accessToken:String?) -> Void)) -> Void {
        
        // We found a token in the keychain, we need to check if it is not expired            
        if let optionalStoredAccessToken:NSString? = self.retrieveAccessTokenFromKeychain() {
            
            // Token expired, attempt to refresh it
            if (self.isAccessTokenExpired()) {
                if let refreshToken = self.retrieveRefreshTokenFromKeychain() {
                    self.refreshToken(refreshToken, newToken: token)
                }
            }
                // Token not expired, use it to authenticate future requests.
            else {
                token(accessToken: optionalStoredAccessToken)
            }
            
        }
        else {
            // First, let's retrieve the autorization_code by login the user in.
            self.retrieveAuthorizationCode { (authorizationCode) -> Void in
                
                if let optionalAuthCode = authorizationCode {
                    // We have the authorization_code, we now need to exchange it for the accessToken by doind a POST request
                    let url:String = CROAuth2Client.tokenURL() + "?grant_type=authorization_code" 
                        + "&client_id=" + CROAuth2Client.clientID()
                        + "&client_secret=" + CROAuth2Client.clientSecret()
                        + "&redirect_uri=" + CROAuth2Client.redirectURI().stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
                        + "&code=" + optionalAuthCode
                    
                    // Trigger the POST request
                    Alamofire.request(.POST, 
                        url, 
                        parameters: nil, 
                        encoding: Alamofire.ParameterEncoding.URL)
                        .responseJSON { (request, response, json, error ) -> Void in   
                            self.postRequestHandler(json, error: error, token: token) 
                    }
                }
            }
        }
    }
    
    // MARK: - Private helper methods
    

    // Retrieves the autorization code by presenting a webView that will let the user login
    private func retrieveAuthorizationCode(authoCode:((authorizationCode:String?) -> Void)) -> Void{
        
        func success(code:String) -> Void {
            println("SUCCESS AND CODE = " + code)
            self.sourceViewController?.dismissViewControllerAnimated(true, completion: nil)
            authoCode(authorizationCode:code)
        }
        
        func failure(error:NSError) -> Void {
            println("ERROR = " + error.description)
            self.sourceViewController?.dismissViewControllerAnimated(true, completion: nil)
            authoCode(authorizationCode:nil)
        }
        
        var authenticationViewController:CRAuthenticationViewController = CRAuthenticationViewController(successCallback:success, failureCallback:failure)
        var navigationController:UINavigationController = UINavigationController(rootViewController: authenticationViewController)
        
        self.sourceViewController?.presentViewController(navigationController, animated:true, completion:nil)
    }
    
    // Checks if the token that is stored in the keychain is expired
    private func isAccessTokenExpired() -> Bool {

        var isTokenExpired: Bool = true
        
        let optionalExpiresIn:NSString? = KeychainService.retrieveStringFromKeychain(kCROAuth2ExpiresInService)
        
        if let expiresInValue = optionalExpiresIn {
            let expiresTimeInterval:NSTimeInterval = expiresInValue.doubleValue
            
            let optionalCreationDate:NSString? = KeychainService.retrieveStringFromKeychain(kCROAuth2CreationDateService)
            
            if let creationDate = optionalCreationDate {
                let creationTimeInterval:NSTimeInterval = creationDate.doubleValue
                
                // need to refresh the token 
                if (NSDate().timeIntervalSince1970 < creationTimeInterval + expiresTimeInterval) {
                    isTokenExpired = false
                }   
            }   
        }
        
        return isTokenExpired
    }
    
    private func retrieveAccessTokenFromKeychain() -> String? {
        return KeychainService.retrieveStringFromKeychain(kCROAuth2AccessTokenService)   
    }
    
    private func retrieveRefreshTokenFromKeychain() -> String? {
        return KeychainService.retrieveStringFromKeychain(kCROAuth2RefreshTokenService)   
    }
    
    // Request a new access token with our refresh token
    func refreshToken(refreshToken:String, newToken:((accessToken:String?) -> Void)) -> Void {
        
        println("Need to refresh the token with refreshToken : " + refreshToken)
        
        let url:String = CROAuth2Client.tokenURL() + "?grant_type=refresh_token" 
            + "&client_id=" + CROAuth2Client.clientID()
            + "&client_secret=" + CROAuth2Client.clientSecret()
            + "&redirect_uri=" + CROAuth2Client.redirectURI().stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
            + "&refresh_token=" + refreshToken
        
        Alamofire.request(.POST, 
            url, 
            parameters: nil, 
            encoding: Alamofire.ParameterEncoding.URL)
            .responseJSON { (request, response, json, error ) -> Void in
                self.postRequestHandler(json, error: error, token: newToken) 
        }
    }
    
    // Extract the accessToken from the JSON response that the authentication server returned
    private func retrieveAccessTokenFromJSONResponse(jsonResponse:AnyObject?) -> String {

        var result:String = String()
        
        if let jsonResult: NSDictionary = jsonResponse as? NSDictionary {
            
            let optionalAccessToken : NSString? = jsonResult["access_token"] as? NSString
            let optionalRefreshToken : NSString? = jsonResult["refresh_token"] as? NSString
            let optionalExpiresIn : NSNumber? = jsonResult["expires_in"] as? NSNumber
            
            // Store the required info for future token refresh in the Keychain.
            if let accessToken = optionalAccessToken {
                result = accessToken
                KeychainService.storeStringToKeychain(accessToken, service: kCROAuth2AccessTokenService)
            }
            if let refreshToken = optionalRefreshToken {
                KeychainService.storeStringToKeychain(refreshToken, service: kCROAuth2RefreshTokenService)
            }
            if let expiresIn = optionalExpiresIn {
                let string:NSString = "1"
                KeychainService.storeStringToKeychain(string, service: kCROAuth2ExpiresInService)
            }
            
            let date:NSTimeInterval = NSDate().timeIntervalSince1970
            KeychainService.storeStringToKeychain(NSString(format: "%f", date), service: kCROAuth2CreationDateService)
        }
        
        return result
    }
    

}

