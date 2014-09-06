//
//  KeychainService.swift
//  CROAuth2Client
//
//  Created by Clement Rousselle on 9/5/14.
//  Copyright (c) 2014 Clement Rousselle. All rights reserved.
//

let account = "OAuth2Tokens"

import Foundation
import Security

class KeychainService : NSObject 
{
    
    class func storeStringToKeychain(stringToStore:NSString, service:CFStringRef) -> Void {
        
        let data: NSData? = stringToStore.dataUsingEncoding(NSUTF8StringEncoding)
        
        if let optionalData = data {
            var keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPassword, service, account, optionalData],                
                forKeys: [kSecClass, kSecAttrService, kSecAttrAccount, kSecValueData])
            
            var status:OSStatus = SecItemAdd(keychainQuery as CFDictionaryRef, nil)
        }
    }
    
    class func retrieveStringFromKeychain(service: CFStringRef) -> NSString? {
        
        // Build the query
        var keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPassword, service, account, kCFBooleanTrue, kSecMatchLimitOne], 
            forKeys: [kSecClass, kSecAttrService, kSecAttrAccount, kSecReturnData, kSecMatchLimit])
        
        // Retrieve the data and convert it
        var dataTypeRef :Unmanaged<AnyObject>?
        let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
        let opaque = dataTypeRef?.toOpaque()
        var contentsOfKeychain: NSString?
        
        if let op = opaque? {
            let retrievedData = Unmanaged<NSData>.fromOpaque(op).takeUnretainedValue()
            
            contentsOfKeychain = NSString(data: retrievedData, encoding: NSUTF8StringEncoding)
            
            if let finalString = contentsOfKeychain {
                println("retrieved from keychain : " + (service as NSString) + "= " + finalString)
                return finalString
            }
            
            
        }
        
        return nil
    }
    
    
    
    
}