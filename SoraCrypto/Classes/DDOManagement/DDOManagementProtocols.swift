/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import Foundation
import IrohaCrypto

public protocol DDOBuilderProtocol {
    func with(signer: IRSignatureCreatorProtocol) -> Self
    func with(encoder: DocumentNodeEncoderProtocol) -> Self
    func with(randomGenerator: RandomGeneratorProtocol) -> Self
    func with(stringCoder: DocumentStringCoderProtocol) -> Self

    func with(decentralizedId: String) -> Self
    func with(publicKeys: [DDOPublicKey]) -> Self
    func with(authentications: [DDOAuthentication]) -> Self
    func with(services: [DDOService]) -> Self
    func with(createdDate: Date) -> Self
    func with(updatedDate: Date) -> Self
    func with(guardian: String) -> Self

    func byAppending(publicKey: DDOPublicKey) -> Self
    func byAppending(authentication: DDOAuthentication) -> Self
    func byAppending(service: DDOService) -> Self

    func with(nonceSize: Int) -> Self
    func with(proofPublicKeyIndex: Int) -> Self

    func build() throws -> DecentralizedDocumentObject
}

public protocol DDOVerifierProtocol {
    func with(signatureVerifier: IRSignatureVerifierProtocol) -> Self
    func with(encoder: DocumentNodeEncoderProtocol) -> Self
    func with(stringCoder: DocumentStringCoderProtocol) -> Self
    func verify(_ ddo: DecentralizedDocumentObject) throws -> Bool
}
