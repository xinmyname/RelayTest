//
//  StringExtensions.swift
//  PhotoMon
//
//  Created by Andy Sherwood on 4/20/16.
//  Copyright © 2016 Clean Water Services. All rights reserved.
//

import Foundation

internal extension String {
    
    init?(fromJsonDictionary:[AnyHashable:Any]) throws {
        
        let data = try JSONSerialization.data(withJSONObject: fromJsonDictionary, options: .prettyPrinted)
        
        guard let text = String(data: data, encoding: String.Encoding.utf8) else {
            throw ErrorFactory.failedJsonDecode
        }
        
        self.init(text)
    }
    
    func asUTF8Data() throws -> Data {
        
        guard let data = self.data(using: String.Encoding.utf8) else {
            throw ErrorFactory.failedDataEncode
        }
        
        return data
    }

    func asJSONDictionary() throws -> [AnyHashable:Any] {
        
        let data = try self.asUTF8Data()

        guard let jsonData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [AnyHashable:Any] else {
            throw ErrorFactory.failedJsonEncode
        }
        
        return jsonData
    }
    
    func asJSONArray() throws -> [Any] {
        
        let data = try self.asUTF8Data()
        
        guard let jsonData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [Any] else {
            throw ErrorFactory.failedJsonEncode
        }
        
        return jsonData
    }

    static let urlCharSet = CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted
    
    func urlEncoded() throws -> String {
        
        guard let encoded = self.addingPercentEncoding(withAllowedCharacters: String.urlCharSet) else {
            throw ErrorFactory.failedUrlEncode
        }
        
        return encoded
    }    
}
