//
//  CRCredentialsHelper.swift
//  GetThere
//
//  Created by Clement Rousselle on 8/24/14.
//  Copyright (c) 2014 Clement Rousselle. All rights reserved.
//

import Foundation

class CRCredentialsHelper : NSObject 
{
    class func sharedInstance() -> CRCredentialsHelper {
        
        struct Instance {
            static let credentialsHelper = CRCredentialsHelper()
        }
        
        return Instance.credentialsHelper
    }
    
    func baseURL() -> String {
        //TODO: ADD YOUR VALUE HERE
        return ""
    }
 
    func authorizeURL() -> String {
        //TODO: ADD YOUR VALUE HERE
        return ""
    }
    
    func tokenURL() -> String {
        //TODO: ADD YOUR VALUE HERE
        return ""
    }
    
    func redirectURI() -> String {
        //TODO: ADD YOUR VALUE HERE
        return ""
    }
    
    func clientID() -> String {
        //TODO: ADD YOUR VALUE HERE
        return ""
    }
    
    func clientSecret() -> String {
        //TODO: ADD YOUR VALUE HERE
        return ""
    }
}
