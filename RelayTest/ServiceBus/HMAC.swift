//
//  HMAC.swift
//  HMACTest
//
//  Created by Andy Sherwood on 7/13/16.
//  Copyright © 2016 Clean Water Serivces. All rights reserved.
//

import Foundation
import CommonCrypto

internal final class HMAC {
    
    private let _algorithm:Algorithm
    private let _key:Data?
    
    init(algorithm:Algorithm, key:String, convertAs:KeyConversion) {
        
        _algorithm = algorithm
        
        switch(convertAs) {
            
        case .asciiBytes:
            _key = key.data(using: .ascii)
            break
        case .utf8Bytes:
            _key = key.data(using: .utf8)
            break
        case .base64Digest:
            _key = Data(base64Encoded: key)
            break
        }
    }
    
    init(algorithm:Algorithm, key:Data) {
        
        _algorithm = algorithm
        _key = key
    }
    
    init(algorithm:Algorithm, key:Array<UInt8>) {
        
        _algorithm = algorithm
        _key = Data(bytes: key)
    }
    
    func hash(data:Data) throws -> Data {

        guard let key = _key else {
            throw ErrorFactory.cryptoKeyInvalid
        }
        
        var resultData:Data? = nil
        
        key.withUnsafeBytes { (keyBytes:UnsafePointer<UInt8>) in
            data.withUnsafeBytes { (dataBytes:UnsafePointer<UInt8>) in
                
                let resultBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: _algorithm.digestLength)
                
                CCHmac(CCHmacAlgorithm(_algorithm.rawValue), keyBytes, key.count, dataBytes, data.count, resultBytes)
                
                resultData = Data(bytesNoCopy: resultBytes, count: _algorithm.digestLength, deallocator: .free)
            }
        }

        if resultData == nil {
            throw ErrorFactory.cryptoFailed
        }
        
        return resultData!
    }

    func hash(text:String, using encoding:String.Encoding = .utf8) throws -> Data {
        
        guard let data = text.data(using: encoding) else {
            throw ErrorFactory.failedToEncode(text: text)
        }
        
        return try self.hash(data: data)
    }
        
    enum Algorithm:Int {
        case sha1
        case md5
        case sha256
        case sha384
        case sha512
        case sha224
        
        var digestLength:Int {
            switch(self) {
            case .sha1: return Int(CC_SHA1_DIGEST_LENGTH)
            case .md5: return Int(CC_MD5_DIGEST_LENGTH)
            case .sha256: return Int(CC_SHA256_DIGEST_LENGTH)
            case .sha384: return Int(CC_SHA384_DIGEST_LENGTH)
            case .sha512: return Int(CC_SHA512_DIGEST_LENGTH)
            case .sha224: return Int(CC_SHA224_DIGEST_LENGTH)
            }
        }
    }
    
    enum KeyConversion {
        case asciiBytes
        case utf8Bytes
        case base64Digest
    }
}
