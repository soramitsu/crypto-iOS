/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import Foundation
import SoraDocuments
import IrohaCrypto

public enum DDOVerifierError: Error {
    case unexpectedDocument
    case noProofPublicKeyFound
    case noPublicKeysFound
    case noAuthentificationFound
}

public class DDOVerifier {
    private var signatureVerifier: IRSignatureVerifierProtocol!
    private var encoder: DocumentNodeEncoderProtocol!
    private var stringCoder: DocumentStringCoderProtocol!
}

extension DDOVerifier: DDOVerifierProtocol {
    public func with(signatureVerifier: IRSignatureVerifierProtocol) -> Self {
        self.signatureVerifier = signatureVerifier
        return self
    }

    public func with(encoder: DocumentNodeEncoderProtocol) -> Self {
        self.encoder = encoder
        return self
    }

    public func with(stringCoder: DocumentStringCoderProtocol) -> Self {
        self.stringCoder = stringCoder
        return self
    }

    public func verify(_ ddo: DecentralizedDocumentObject) throws -> Bool {
        guard ddo.publicKey.count > 0 else {
            throw DDOVerifierError.noPublicKeysFound
        }

        guard ddo.authentication.count > 0 else {
            throw DDOVerifierError.noAuthentificationFound
        }

        guard let proofPublicKey = ddo.publicKey.first(where: { $0.pubKeyId == ddo.proof.creator }) else {
            throw DDOVerifierError.noProofPublicKeyFound
        }

        let proofPublicKeyData = try stringCoder.decodeData(proofPublicKey.publicKey)

        let proofPublicKeyWrapper = try IRIrohaPublicKey(rawData: proofPublicKeyData)

        let jsonEncoder = JSONEncoder()
        let ddoNodeData = try jsonEncoder.encode(ddo)
        let proofNodeData = try jsonEncoder.encode(ddo.proof)

        let documentSerializer = JSONDocumentSerializer()
        let ddoAny = try documentSerializer.deserialize(data: ddoNodeData)
        let optionsAny = try documentSerializer.deserialize(data: proofNodeData)

        guard var ddoNode = ddoAny as? DocumentNodeProtocol else {
            throw DDOVerifierError.unexpectedDocument
        }

        guard var optionsNode = optionsAny as? DocumentNodeProtocol else {
            throw DDOVerifierError.unexpectedDocument
        }

        ddoNode.remove(for: DecentralizedDocumentObject.CodingKeys.proof.rawValue)
        optionsNode.remove(for: DDOProof.CodingKeys.signatureValue.rawValue)

        let documentData = try encoder.encode(ddoNode)
        let optionsData = try encoder.encode(optionsNode)

        let originalData = documentData + optionsData

        let signatureData = try stringCoder.decodeData(ddo.proof.signatureValue)

        let signature = try IRIrohaSignature(rawData: signatureData)

        return signatureVerifier.verify(signature,
                                        forOriginalData: originalData,
                                        usingPublicKey: proofPublicKeyWrapper)
    }
}
