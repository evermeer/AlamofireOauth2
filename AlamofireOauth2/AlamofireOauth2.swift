
import Foundation
import UIKit

public func UsingOauth2(settings: Oauth2Settings?,controller: UIViewController, performWithToken: (token: String) -> (), errorHandler: () -> () ) {
    if settings == nil {
        println("ERROR: No Oauth2 settings provided")
        errorHandler()
        return
    }
    var client = OAuth2Client(outh2Settings: settings!, controller: controller)
    client.retrieveAuthToken({ (authToken) -> Void in
        if let optionnalAuthToken = authToken {
            if authToken != "" {
                println("Received access token " + optionnalAuthToken)
                performWithToken(token: optionnalAuthToken)
                return                
            }
        }
        println("ERROR: Unable to get access token ")
        errorHandler()
        
    })
}