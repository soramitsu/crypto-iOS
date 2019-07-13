/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import Foundation

public enum DDOServiceError: Error {
    case typeMissing
    case serviceEndpointMissing
}

public struct DDOService: Equatable {
    enum CodingKeys: String, CodingKey {
        case type
        case serviceEndpoint
    }

    public var type: String
    public var serviceEndpoint: String
    public var options: [String: String]

    public init(type: String, serviceEndpoint: String, options: [String: String]) {
        self.type = type
        self.serviceEndpoint = serviceEndpoint
        self.options = options
    }
}

extension DDOService: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DDODynamicCodingKey.self)

        if let encodingKey = DDODynamicCodingKey(stringValue: CodingKeys.type.rawValue) {
            try container.encode(type, forKey: encodingKey)
        }

        if let encodingKey = DDODynamicCodingKey(stringValue: CodingKeys.serviceEndpoint.rawValue) {
            try container.encode(serviceEndpoint, forKey: encodingKey)
        }

        for (optionKey, optionValue) in options {
            if let encodingKey = DDODynamicCodingKey(stringValue: optionKey) {
                try container.encode(optionValue, forKey: encodingKey)
            }
        }
    }
}

extension DDOService: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DDODynamicCodingKey.self)

        var optionKeys = container.allKeys

        if let encodingKey = DDODynamicCodingKey(stringValue: CodingKeys.type.rawValue) {
            type = try container.decode(String.self, forKey: encodingKey)
            optionKeys.removeAll { $0.stringValue == encodingKey.stringValue }
        } else {
            throw DDOServiceError.typeMissing
        }

        if let encodingKey = DDODynamicCodingKey(stringValue: CodingKeys.serviceEndpoint.rawValue) {
            serviceEndpoint = try container.decode(String.self, forKey: encodingKey)
            optionKeys.removeAll { $0.stringValue == encodingKey.stringValue }
        } else {
            throw DDOServiceError.serviceEndpointMissing
        }

        options = [String: String]()

        for decodingKey in optionKeys {
            options[decodingKey.stringValue] = try container.decode(String.self, forKey: decodingKey)
        }
    }
}
