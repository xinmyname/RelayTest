//
//  AzureServiceBus.swift
//  PhotoMon
//
//  Created by Andy Sherwood on 10/9/15.
//  Copyright © 2015 Clean Water Services. All rights reserved.
//

import Foundation

public final class ServiceBusRelay : NSObject
{
    private let _serviceUrl:URL?
    private let _sasKeyName:String
    private let _hmac:HMAC
    private let _entityPath:String?
    private let _relayNamespace:String

    @objc
    public init(relayNamespace:String, sasKeyName:String, sasPrimaryKey:String, entityPath:String? = nil)
    {
        if let entityPath = entityPath {
            _serviceUrl = URL(string: "https://\(relayNamespace).servicebus.windows.net/\(entityPath)/")
        } else {
            _serviceUrl = URL(string: "https://\(relayNamespace).servicebus.windows.net/")
        }

        _sasKeyName = sasKeyName
        _hmac = HMAC(algorithm: .sha256, key: sasPrimaryKey, convertAs: .utf8Bytes)
        _relayNamespace = relayNamespace
        _entityPath = entityPath
    }

    @objc
    public func makeRequest(forRel rel:String) throws -> URLRequest {
        return try self.makeRequest(withData:nil, forRel:rel)
    }

    @objc
    public func makeRequest(withText text:String, forRel rel:String) throws -> URLRequest {

        let data = text.data(using: .utf8)
        return try self.makeRequest(withData:data, forRel:rel)
    }

    @objc
    public func makeRequest(withJson json:Any, forRel rel:String) throws -> URLRequest {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        var request = try self.makeRequest(withData: data, forRel: rel)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }

    @objc
    public func makeRequest(withData data:Data?, forRel rel:String) throws -> URLRequest {

        guard let serviceUrl = _serviceUrl else {
            throw ErrorFactory.invalidRequestUrl
        }

        guard let url = URL(string: rel, relativeTo: serviceUrl) else  {
            throw ErrorFactory.invalidRequestUrl
        }

        var request = URLRequest(url: url)
        request.httpBody = data

        if data != nil {
            request.httpMethod = "POST"
        }

        let authorization = try self.makeSharedAccessSignature(for: url)
        request.setValue(authorization, forHTTPHeaderField: "Authorization")

        return request
    }

    @objc
    public func makeSecureHybridConnectionSenderUrl(withId id:String? = nil) throws -> URL {

        guard let entityPath = _entityPath else {
            throw ErrorFactory.missingEntityPath
        }

        guard let serviceUrl = _serviceUrl else {
            throw ErrorFactory.invalidRequestUrl
        }

        let hcId = (id != nil)
            ? "&sb-hc-id=\(id!)"
            : ""

        let hcToken = try makeSharedAccessSignature(for: serviceUrl).urlEncoded()

        guard let url = URL(string: "wss://\(_relayNamespace).servicebus.windows.net/$hc/\(entityPath)?sb-hc-action=connect\(hcId)&sb-hc-token=\(hcToken)") else {
            throw ErrorFactory.failedToCreateHybridUrl
        }

        return url
    }

    private func makeSharedAccessSignature(for url:URL) throws -> String {

        let urlText = url.absoluteString

        let expiryDate = Date(timeIntervalSinceNow: 3600)
        let se = Int(expiryDate.timeIntervalSince1970)
        let skn = _sasKeyName
        let sr = try urlText.urlEncoded().lowercased()
        let sig:String = try _hmac.hash(text: "\(sr)\n\(se)").base64EncodedString().urlEncoded()

        return "SharedAccessSignature sr=\(sr)&sig=\(sig)&se=\(se)&skn=\(skn)"
    }
}
