/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import Foundation

public enum DDOAuthenticationType: String, Codable {
    case ed25519Sha3 = "Ed25519Sha3Authentication"
}

public struct DDOAuthentication: Codable, Equatable {
    enum CodingKeys: String, CodingKey {
        case type
        case publicKey
    }

    public var type: DDOAuthenticationType
    public var publicKey: String?

    public init(type: DDOAuthenticationType, publicKey: String?) {
        self.type = type
        self.publicKey = publicKey
    }
}
