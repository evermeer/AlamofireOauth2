//
//  AuthenticationViewController.swift
//  GetThere
//
//  Created by Clement Rousselle on 8/25/14.
//  Copyright (c) 2014 Clement Rousselle. All rights reserved.
//

import Foundation
import UIKit

class CRAuthenticationViewController : UIViewController, UIWebViewDelegate{

    let expectedState:String = "authDone"
    
    var webView: UIWebView?
    
    var successCallback : ((code:String)-> Void)?
    var failureCallback : ((error:NSError) -> Void)?

    var isRetrievingAuthCode : Bool? = false
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    init(successCallback:((code:String)-> Void), failureCallback:((error:NSError) -> Void)) {
        
        super.init()
        
        self.successCallback = successCallback
        self.failureCallback = failureCallback
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.title = "Login"
        
        self.webView = UIWebView(frame: self.view.bounds);
        
        if let bindCheck = self.webView {
            self.webView!.backgroundColor = UIColor.clearColor()
            self.webView!.scalesPageToFit = true
            self.webView!.delegate = self
            self.view.addSubview(self.webView!)
        }
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Bordered, target: self, action: Selector("cancelAction"))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // TO alter if more parameters neede
        var url:String! = CROAuth2Client.authorizeURL() + "?response_type=code&client_id=" + CROAuth2Client.clientID() + "&state=" + expectedState + "&redirect_uri=" + CROAuth2Client.redirectURI().stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
        let urlRequest : NSURLRequest = NSURLRequest(URL: NSURL(string: url))
        
        self.webView!.loadRequest(urlRequest)
    }
    
    
    func cancelAction() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func webView(webView: UIWebView!, shouldStartLoadWithRequest request: NSURLRequest!, navigationType: UIWebViewNavigationType) -> Bool {
        
        let url : NSString = request.URL.absoluteString!
        
        self.isRetrievingAuthCode = url.hasPrefix(CROAuth2Client.redirectURI())
        
        if (self.isRetrievingAuthCode!) {
            if(url.rangeOfString("error").location != NSNotFound) {
                let error:NSError = NSError(domain:"CROAuth2UnknownErrorDomain", code:0, userInfo: nil)
                self.failureCallback!(error:error)
            } else {
                
                let optionnalState:String? = self.extractParameterFromUrl("state", url: url)
                
                if let state = optionnalState {
                    if (state == expectedState) {
                        
                        let optionnalCode:String? = self.extractParameterFromUrl("code", url: url)
                        if let code = optionnalCode {
                            self.successCallback!(code:code)
                        }
                    }
                }
            }
        }
        
        return true
            
    }
    
    func webView(webView: UIWebView!, didFailLoadWithError error: NSError!) {
        if (!self.isRetrievingAuthCode!) {
            self.failureCallback!(error: error)
        }
    }
        
    
    func extractParameterFromUrl(parameterName:NSString, url:NSString) -> String? {
        
        if(url.rangeOfString("?").location == NSNotFound) {
            return nil
        }
        
        if let urlString: String = url.componentsSeparatedByString("?")[1] as? String {
            var dict = Dictionary <String, String>()
            
            for param in urlString.componentsSeparatedByString("&") {
                var array = Array <AnyObject>()
                array = param.componentsSeparatedByString("=")
                let name:String = array[0] as String
                let value:String = array[1] as String
                
                dict[name] = value
            }
            if let result = dict[parameterName] {
                return result
            }
        }
        return nil
    }
}


