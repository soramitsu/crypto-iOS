/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import Foundation

public struct DecentralizedDocumentObject: Codable, Equatable {
    public enum CodingKeys: String, CodingKey {
        case decentralizedId = "id"
        case created
        case updated
        case publicKey
        case authentication
        case guardian
        case service
        case proof
    }

    public var decentralizedId: String
    public var created: String?
    public var updated: String?
    public var publicKey: [DDOPublicKey]
    public var authentication: [DDOAuthentication]
    public var guardian: String?
    public var service: [DDOService]?
    public var proof: DDOProof

    public init(decentralizedId: String,
                created: String?,
                updated: String?,
                publicKey: [DDOPublicKey],
                authentication: [DDOAuthentication],
                guardian: String?,
                service: [DDOService]?,
                proof: DDOProof) {
        self.decentralizedId = decentralizedId
        self.created = created
        self.updated = updated
        self.publicKey = publicKey
        self.authentication = authentication
        self.guardian = guardian
        self.service = service
        self.proof = proof
    }
}
