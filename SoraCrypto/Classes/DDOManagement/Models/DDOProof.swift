/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import Foundation

public enum DDOProofType: String, Codable {
    case ed25519Sha3 = "Ed25519Sha3Signature"
}

public struct DDOProof: Codable, Equatable {
    enum CodingKeys: String, CodingKey {
        case type
        case created
        case creator
        case signatureValue
        case nonce
    }

    public var type: DDOProofType
    public var created: String
    public var creator: String
    public var signatureValue: String
    public var nonce: String

    public init(type: DDOProofType,
                created: String,
                creator: String,
                signatureValue: String,
                nonce: String) {
        self.type = type
        self.created = created
        self.creator = creator
        self.signatureValue = signatureValue
        self.nonce = nonce
    }
}
