//
//  SBNotificationHubHelper.swift
//  AzureNotifyTest
//
//  Created by Andy Sherwood on 5/23/16.
//  Copyright © 2016 Clean Water Serivces. All rights reserved.
//

import Foundation

internal final class ErrorFactory {
    
    static var nilDeviceToken:Error {
        get { return self.error(msg:"Device Token can't be nil") }
    }
    
    static var registrationNotFound:Error {
        get { return self.error(msg:"Registration not found") }
    }

    static var cryptoSigning:Error {
        get { return self.error(msg:"Crypto signing error") }
    }

    static var invalidRequestUrl:Error {
        get { return self.error(msg:"Invalid request URL") }
    }

    static var locationHeaderMissing:Error {
        get { return self.error(msg:"Location header missing from response") }
    }
    
    static var registrationDataMissing:Error {
        get { return self.error(msg:"No registration data to parse") }
    }

    static var failedToParseRegistration:Error {
        get { return self.error(msg:"Failed to parse registration") }
    }
    
    static var cryptoKeyInvalid:Error {
        get { return self.error(msg:"Crypto key is invalid") }
    }

    static var cryptoFailed:Error {
        get { return self.error(msg:"Crypto failed") }
    }
    
    static var failedDataEncode:Error {
        get { return self.error(msg:"Failed to encode data") }
    }

    static var failedJsonEncode:Error {
        get { return self.error(msg:"Failed to encode JSON") }
    }

    static var failedJsonDecode:Error {
        get { return self.error(msg:"Failed to decode JSON") }
    }
    
    static var failedUrlEncode:Error {
        get { return self.error(msg:"Failed to encode URL") }
    }

    
    static func failedToEncode(text:String) -> Error {
        return self.error(msg:"Failed to encode text: \(text)")
    }
    
    static func invalid(location:String) -> Error {
        return self.error(msg:"Invalid location: \(location)")
    }

    static func invalidResponse(from url:URL?) -> Error {
        let urlText = url?.absoluteString ?? "(nil)"
        return self.error(msg: "Invalid response from: \(urlText)")
    }

    static func unableToExtractRegistration(from locationUrl:URL) -> Error {
        let urlText = locationUrl.absoluteString
        return self.error(msg: "Unable to extract registration ID from location header: \(urlText)")
    }
    
    static func upsertFailed(with message:String?, code:Int) -> Error {
        let msgText = message ?? "(nil)"
        return self.error(msg: "Upsert registration failed: \(msgText)", code:code)
    }


    static var missingEntityPath:Error {
        get { return self.error(msg: "An entity path is required to build a Hybrid Connection URL")}
    }

    static var failedToCreateHybridUrl:Error {
        get { return self.error(msg:"Failed to create Hybrid Connection URL") }
    }


    private static func error(msg:String, code:Int = -1) -> Error {
        return NSError(domain: "WindowsAzure", code: code, userInfo: [NSLocalizedDescriptionKey:msg])
    }
}
