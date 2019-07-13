/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import XCTest
import SoraCrypto
import SoraDocuments

class DocumentOneCoderTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSimpleDocument() {
        // given
        var document = JSONDocumentNode()
        document.set(integer: 1, for: "a")
        document.set(string: "2", for: "b")

        // when
        let encoder = DocumentOneCoder()
        guard let data = try? encoder.encode(document) else {
            XCTFail()
            return
        }

        // then
        guard let dataString = String(data: data, encoding: .utf8) else {
            XCTFail()
            return
        }

        XCTAssertEqual(dataString, "d1:ai1e1:b1:2e")
    }

    func testNormalDocumentCoding() {
        // given
        var document = JSONDocumentNode()
        document.set(string: "string", for: "str")
        document.set(integer: 100500, for: "num")

        var subnode = JSONDocumentNode()
        subnode.set(integer: 9, for: "a")
        subnode.set(integer: 10, for: "c")

        document.set(node: subnode, for: "dict")

        // when
        let encoder = DocumentOneCoder()
        guard let data = try? encoder.encode(document) else {
            XCTFail()
            return
        }

        // then
        guard let dataString = String(data: data, encoding: .utf8) else {
            XCTFail()
            return
        }

        XCTAssertEqual(dataString, "d4:dictd1:ai9e1:ci10ee3:numi100500e3:str6:stringe")
    }

    func testUT8EncodedStrings() {
        // given
        var document = JSONDocumentNode()
        document.set(string: "привет мир", for: "r")
        document.set(string: "こんにちは世界", for: "j")

        // when
        let encoder = DocumentOneCoder()
        guard let data = try? encoder.encode(document) else {
            XCTFail()
            return
        }

        // then
        guard let dataString = String(data: data, encoding: .utf8) else {
            XCTFail()
            return
        }

        XCTAssertEqual(dataString, "d1:j21:こんにちは世界1:r19:привет мирe")
    }

    func testNormalDocumentCodingWithReference() {
        // given
        var document = JSONDocumentNode()
        document.set(string: "string", for: "str")
        document.set(integer: 100500, for: "num")

        var subnode = JSONDocumentNode()
        subnode.set(integer: 9, for: "a")
        subnode.set(integer: 10, for: "c")

        document.set(node: subnode, for: "dict")

        let reference = JSONDocumentReference(referenceName: "file")
        document.set(reference: reference, for: "aim")

        // when
        let encoder = DocumentOneCoder()
        guard let data = try? encoder.encode(document) else {
            XCTFail()
            return
        }

        // then
        guard let dataString = String(data: data, encoding: .utf8) else {
            XCTFail()
            return
        }

        XCTAssertEqual(dataString, "d3:aim4:file4:dictd1:ai9e1:ci10ee3:numi100500e3:str6:stringe")
    }

    func testDDOOneCoding() {
        let did = "did:sora:username"

        let publicKey = DDOPublicKey(
            pubKeyId: "did:sora:username#keys-1",
            type: .ed25519Sha3Verification,
            owner: "did:sora:username",
            publicKey: "b8bf218fe98e6b505b9ebdff5852d9db8df38d130ee914d531b06bb7be68efe4"
        )

        let created = "2018-09-14T10:07:30Z"

        let authentication = DDOAuthentication(type: .ed25519Sha3, publicKey: "did:sora:username#keys-1")
        let proof = DDOProof(
            type: .ed25519Sha3,
            created: created,
            creator: "did:sora:username#keys-1",
            signatureValue: "4b795622ae631dade793125648b73e66c181be7d4458ced245be85b991c5b069a227badcb6ecc758a13f5aba012b450f1f049b80f88d9e9af73c87a9afa77208",
            nonce: "eab8d59aa53681c63559b2133083e3af7be41aafec10bf0ae60e8781216f1f7e"
        )

        let ddo = DecentralizedDocumentObject(decentralizedId: did,
                                              created: created,
                                              updated: nil,
                                              publicKey: [publicKey],
                                              authentication: [authentication],
                                              guardian: nil,
                                              service: nil,
                                              proof: proof)

        guard let ddoData = try? JSONEncoder().encode(ddo) else {
            XCTFail()
            return
        }

        guard let node = try? JSONDocumentSerializer().deserialize(data: ddoData) else {
            XCTFail()
            return
        }

        guard var jsonNode = node as? JSONDocumentNode else {
            XCTFail()
            return
        }

        jsonNode.remove(for: DecentralizedDocumentObject.CodingKeys.proof.rawValue)

        guard let oneCodedData = try? DocumentOneCoder().encode(jsonNode) else {
            XCTFail()
            return
        }

        guard let dataString = String(data: oneCodedData, encoding: .utf8) else {
            XCTFail()
            return
        }

        let expected = "d14:authenticationld9:publicKey24:did:sora:username#keys-14:type25:Ed25519Sha3Authenticationee7:created20:2018-09-14T10:07:30Z2:id17:did:sora:username9:publicKeyld2:id24:did:sora:username#keys-15:owner17:did:sora:username9:publicKey64:b8bf218fe98e6b505b9ebdff5852d9db8df38d130ee914d531b06bb7be68efe44:type26:Ed25519Sha3VerificationKeyeee"

        XCTAssertEqual(dataString, expected)
    }

}
