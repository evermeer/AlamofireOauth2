
import Foundation
import UIKit

public func UsingOauth2(settings: Oauth2Settings?, performWithToken: (token: String) -> (), errorHandler: () -> () ) {
    if settings == nil {
        print("ERROR: No Oauth2 settings provided")
        errorHandler()
        return
    }
    let client = OAuth2Client(outh2Settings: settings!)
    client.retrieveAuthToken({ (authToken) -> Void in
        if let optionnalAuthToken = authToken {
            if authToken != "" {
                print("Received access token " + optionnalAuthToken)
                performWithToken(token: optionnalAuthToken)
                return                
            }
        }
        print("ERROR: Unable to get access token ")
        errorHandler()
        
    })
}