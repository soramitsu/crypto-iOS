/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import Foundation

public enum DDOPublicKeyType: String, Codable {
    case ed25519Sha3Verification = "Ed25519Sha3VerificationKey"
}

public struct DDOPublicKey: Codable, Equatable {
    enum CodingKeys: String, CodingKey {
        case pubKeyId = "id"
        case type
        case owner
        case publicKey
    }

    public var pubKeyId: String
    public var type: DDOPublicKeyType
    public var owner: String?
    public var publicKey: String

    public init(pubKeyId: String,
                type: DDOPublicKeyType,
                owner: String?,
                publicKey: String) {
        self.pubKeyId = pubKeyId
        self.type = type
        self.owner = owner
        self.publicKey = publicKey
    }
}
