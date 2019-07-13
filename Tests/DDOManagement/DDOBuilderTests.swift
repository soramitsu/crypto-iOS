/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import XCTest
import SoraCrypto
import IrohaCrypto

class DDOBuilderTests: XCTestCase {
    var builder: DDOBuilder!
    var keypair: IRCryptoKeypair!

    override func setUp() {
        super.setUp()

        keypair = IREd25519KeyFactory().createRandomKeypair() as? IRCryptoKeypair

        let signer = IREd25519Sha512Signer(privateKey: keypair.privateKey())!

        builder = DDOBuilder.createDefault().with(signer: signer)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testDDOBuldingAndVerification() {
        // given
        let ddoFactory = DDOFactory()
        let decentralizedId = ddoFactory.createDecentralizedIdFrom(username: Constants.dummyUsername,
                                                                   domain: Constants.dummyDecentralizedIdDomain)

        let ddoPublicKeyId = ddoFactory.createPublicKeyIdFrom(username: Constants.dummyUsername,
                                                              domain: Constants.dummyDecentralizedIdDomain,
                                                              ddoIndex: 1)

        let ddoPublicKey = DDOPublicKey(pubKeyId: ddoPublicKeyId,
                                        type: .ed25519Sha3Verification,
                                        owner: decentralizedId,
                                        publicKey: keypair.publicKey().rawData().toHexString())

        let authentication = DDOAuthentication(type: .ed25519Sha3, publicKey: ddoPublicKey.pubKeyId)

        builder = builder.with(decentralizedId: decentralizedId)
            .byAppending(publicKey: ddoPublicKey)
            .byAppending(authentication: authentication)

        // when
        guard let ddo = try? builder.build() else {
            XCTFail()
            return
        }

        // then
        let ddoData = try! JSONEncoder().encode(ddo)
        print(String(data: ddoData, encoding: .utf8)!)

        let verifier = DDOVerifier.createDefault()

        guard let result = try? verifier.verify(ddo) else {
            XCTFail()
            return
        }

        XCTAssertTrue(result)
    }

    func testDDOBuldingAndVerificationWithAllFields() {
        // given
        let ddoFactory = DDOFactory()
        let decentralizedId = ddoFactory.createDecentralizedIdFrom(username: Constants.dummyUsername,
                                                                   domain: Constants.dummyDecentralizedIdDomain)
        let guardian = ddoFactory.createDecentralizedIdFrom(username: Constants.dummyEmail,
                                                            domain: Constants.dummyDecentralizedIdDomain)

        let dateConverter = DocumentStringCoder()
        let createdDate = Date(timeIntervalSince1970: 100)
        let updatedDate = Date(timeIntervalSince1970: 1000)

        let ddoPublicKeyId = ddoFactory.createPublicKeyIdFrom(username: Constants.dummyUsername,
                                                              domain: Constants.dummyDecentralizedIdDomain,
                                                              ddoIndex: 1)

        let ddoPublicKey = DDOPublicKey(pubKeyId: ddoPublicKeyId,
                                        type: .ed25519Sha3Verification,
                                        owner: decentralizedId, publicKey: keypair.publicKey().rawData().toHexString())

        let ddoAuthentication = DDOAuthentication(type: .ed25519Sha3, publicKey: ddoPublicKey.pubKeyId)

        let service = DDOService(type: "GenericService",
                                 serviceEndpoint: "http://google.com",
                                 options: ["optionKey": "optionValue"])

        // when
        builder = builder.with(decentralizedId: decentralizedId)
            .byAppending(publicKey: ddoPublicKey)
            .byAppending(authentication: ddoAuthentication)
            .with(guardian: guardian)
            .with(createdDate: createdDate)
            .with(updatedDate: updatedDate)
            .byAppending(service: service)

        guard let ddo = try? builder.build() else {
            XCTFail()
            return
        }

        // then
        XCTAssertEqual(ddo.decentralizedId, decentralizedId)
        XCTAssertEqual(ddo.publicKey, [ddoPublicKey])
        XCTAssertEqual(ddo.authentication, [ddoAuthentication])
        XCTAssertEqual(ddo.service, [service])
        XCTAssertEqual(ddo.created, try? dateConverter.encode(createdDate))
        XCTAssertEqual(ddo.updated, try? dateConverter.encode(updatedDate))
        XCTAssertEqual(ddo.guardian, guardian)

        let verifier = DDOVerifier.createDefault()

        guard let result = try? verifier.verify(ddo) else {
            XCTFail()
            return
        }

        XCTAssertTrue(result)
    }

}
