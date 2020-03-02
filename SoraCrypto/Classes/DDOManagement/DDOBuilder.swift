/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import Foundation
import IrohaCrypto
import SoraDocuments

public enum DDOBuilderError: Error {
    case nonceGenerationFailed
    case noPublicKeysFound
    case noAuthentificationFound
    case publicKeyIndexOutOfRange
}

public class DDOBuilder {
    private var signer: IRSignatureCreatorProtocol!
    private var encoder: DocumentNodeEncoderProtocol!
    private var randomGenerator: RandomGeneratorProtocol!
    private var stringCoder: DocumentStringCoderProtocol!

    private var nonceSize: Int = 8
    private var proofPublicKeyIndex: Int = 0

    private var decentralizedId: String!
    private var publicKeys = [DDOPublicKey]()
    private var authentications = [DDOAuthentication]()
    private var services: [DDOService]?

    private var createdDate: Date = Date()
    private var updatedDate: Date = Date()
    private var guardian: String?

    private func createPublicKeyListNode() throws -> [JSONDocumentNode] {
        guard publicKeys.count > 0 else {
            throw DDOBuilderError.noPublicKeysFound
        }

        let publicKeyNodeList: [JSONDocumentNode] = publicKeys.map { (publicKey) in
            var publicKeyNode = JSONDocumentNode()
            publicKeyNode.set(string: publicKey.pubKeyId, for: DDOPublicKey.CodingKeys.pubKeyId.rawValue)
            publicKeyNode.set(string: publicKey.type.rawValue, for: DDOPublicKey.CodingKeys.type.rawValue)

            if let owner = publicKey.owner {
                publicKeyNode.set(string: owner, for: DDOPublicKey.CodingKeys.owner.rawValue)
            }

            publicKeyNode.set(string: publicKey.publicKey, for: DDOPublicKey.CodingKeys.publicKey.rawValue)

            return publicKeyNode
        }

        return publicKeyNodeList
    }

    private func createAuthentificationListNode() throws -> [JSONDocumentNode] {
        guard authentications.count > 0 else {
            throw DDOBuilderError.noAuthentificationFound
        }

        let authentificationNodeList: [JSONDocumentNode] = authentications.map { (authentication) in
            var authentificationNode = JSONDocumentNode()
            authentificationNode.set(string: authentication.type.rawValue,
                                     for: DDOAuthentication.CodingKeys.type.rawValue)

            if let publicKey = authentication.publicKey {
                authentificationNode.set(string: publicKey, for: DDOAuthentication.CodingKeys.publicKey.rawValue)
            }

            return authentificationNode
        }

        return authentificationNodeList
    }

    private func createServiceListNode() -> [JSONDocumentNode]? {
        guard let existingServices = services else {
            return nil
        }

        let serviceNodeList: [JSONDocumentNode] = existingServices.map { service in
            var serviceNode = JSONDocumentNode()

            serviceNode.set(string: service.type,
                            for: DDOService.CodingKeys.type.rawValue)

            serviceNode.set(string: service.serviceEndpoint,
                            for: DDOService.CodingKeys.serviceEndpoint.rawValue)

            for (optionKey, optionValue) in service.options {
                serviceNode.set(string: optionValue, for: optionKey)
            }

            return serviceNode
        }

        return serviceNodeList
    }

    private func createProofFrom(document: JSONDocumentNode) throws -> DDOProof {
        guard proofPublicKeyIndex >= 0 && proofPublicKeyIndex < publicKeys.count else {
            throw DDOBuilderError.publicKeyIndexOutOfRange
        }

        guard let nonceBytes = randomGenerator.generate(size: nonceSize) else {
            throw DDOBuilderError.nonceGenerationFailed
        }

        let nonce = try stringCoder.encode(Data(nonceBytes))
        let creator = publicKeys[proofPublicKeyIndex].pubKeyId
        let createdString = try stringCoder.encode(createdDate)

        var options = JSONDocumentNode()
        options.set(string: createdString, for: DDOProof.CodingKeys.created.rawValue)
        options.set(string: DDOProofType.ed25519Sha3.rawValue, for: DDOProof.CodingKeys.type.rawValue)
        options.set(string: creator, for: DDOProof.CodingKeys.creator.rawValue)
        options.set(string: nonce, for: DDOProof.CodingKeys.nonce.rawValue)

        let documentData = try encoder.encode(document)
        let optionsData = try encoder.encode(options)

        let signature = try signer.sign(documentData + optionsData)

        let signatureString = try stringCoder.encode(signature.rawData())

        return DDOProof(type: DDOProofType.ed25519Sha3, created: createdString,
                        creator: creator, signatureValue: signatureString, nonce: nonce)
    }
}

extension DDOBuilder: DDOBuilderProtocol {
    public func with(signer: IRSignatureCreatorProtocol) -> Self {
        self.signer = signer
        return self
    }

    public func with(encoder: DocumentNodeEncoderProtocol) -> Self {
        self.encoder = encoder
        return self
    }

    public func with(randomGenerator: RandomGeneratorProtocol) -> Self {
        self.randomGenerator = randomGenerator
        return self
    }

    public func with(stringCoder: DocumentStringCoderProtocol) -> Self {
        self.stringCoder = stringCoder
        return self
    }

    public func with(decentralizedId: String) -> Self {
        self.decentralizedId = decentralizedId
        return self
    }

    public func with(publicKeys: [DDOPublicKey]) -> Self {
        self.publicKeys = publicKeys
        return self
    }

    public func with(authentications: [DDOAuthentication]) -> Self {
        self.authentications = authentications
        return self
    }

    public func with(services: [DDOService]) -> Self {
        self.services = services
        return self
    }

    public func with(guardian: String) -> Self {
        self.guardian = guardian
        return self
    }

    public func with(createdDate: Date) -> Self {
        self.createdDate = createdDate
        return self
    }

    public func with(updatedDate: Date) -> Self {
        self.updatedDate = updatedDate
        return self
    }

    public func with(nonceSize: Int) -> Self {
        self.nonceSize = nonceSize
        return self
    }

    public func with(proofPublicKeyIndex: Int) -> Self {
        self.proofPublicKeyIndex = proofPublicKeyIndex
        return self
    }

    public func byAppending(publicKey: DDOPublicKey) -> Self {
        publicKeys.append(publicKey)
        return self
    }

    public func byAppending(authentication: DDOAuthentication) -> Self {
        authentications.append(authentication)
        return self
    }

    public func byAppending(service: DDOService) -> Self {
        if services == nil {
            services = [DDOService]()
        }

        services?.append(service)
        return self
    }

    public func build() throws -> DecentralizedDocumentObject {
        var document = JSONDocumentNode()

        document.set(string: decentralizedId,
                     for: DecentralizedDocumentObject.CodingKeys.decentralizedId.rawValue)

        let publicKeyListNode = try createPublicKeyListNode()
        document.set(list: publicKeyListNode,
                     for: DecentralizedDocumentObject.CodingKeys.publicKey.rawValue)

        let authentificationListNode = try createAuthentificationListNode()
        document.set(list: authentificationListNode,
                     for: DecentralizedDocumentObject.CodingKeys.authentication.rawValue)

        if let serviceListNode = createServiceListNode() {
            document.set(list: serviceListNode,
                         for: DecentralizedDocumentObject.CodingKeys.service.rawValue)
        }

        let createdString = try stringCoder.encode(createdDate)
        document.set(string: createdString, for: DecentralizedDocumentObject.CodingKeys.created.rawValue)

        let updatedString = try stringCoder.encode(updatedDate)
        document.set(string: updatedString, for: DecentralizedDocumentObject.CodingKeys.updated.rawValue)

        if let existingGuardian = guardian {
            document.set(string: existingGuardian, for: DecentralizedDocumentObject.CodingKeys.guardian.rawValue)
        }

        let proof = try createProofFrom(document: document)

        return DecentralizedDocumentObject(decentralizedId: decentralizedId,
                                           created: createdString,
                                           updated: updatedString,
                                           publicKey: publicKeys,
                                           authentication: authentications,
                                           guardian: guardian,
                                           service: services,
                                           proof: proof)
    }
}
