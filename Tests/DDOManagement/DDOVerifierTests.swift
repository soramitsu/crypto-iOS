/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import XCTest
import SoraCrypto

class DDOVerifierTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testVerifierWithOnePublicAndAuth() {
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

        let verifier = DDOVerifier.createDefault()

        guard let result = try? verifier.verify(ddo) else {
            XCTFail()
            return
        }

        XCTAssertTrue(result)
    }

    func testVerifyFromRawJSON() {
        let jsonString = """
{
        \"id\": \"did:sora:bogdan\",
        \"publicKey\": [
        {
        \"type\": \"Ed25519Sha3VerificationKey\",
        \"id\": \"did:sora:bogdan#keys-1\",
        \"publicKey\": \"43eeb17f0bab10dd51ab70983c25200a1742d31b3b7b54c38c34d7b827b26eed\"
        }
        ],
        \"authentication\": [
        {
        \"type\": \"Ed25519Sha3Authentication\",
        \"publicKey\": \"did:sora:bogdan#keys-1\"
        }
        ],
        \"service\": [
        {
        \"type\": \"GenericService\",
        \"id\": \"did:sora:bogdan#service-1\",
        \"serviceEndpoint\": \"https://google.com/\"
        }
        ],
        \"created\": \"1970-01-01T00:00:00Z\",
        \"proof\": {
            \"type\": \"Ed25519Sha3Signature\",
            \"created\": \"1970-01-01T00:00:00Z\",
            \"creator\": \"did:sora:bogdan#keys-1\",
            \"nonce\": \"nonce\",
            \"signatureValue\": \"05fce5dab2530b751f5e11bdb837a539cd3e0cd9477e2b0bb2907a9faa1d19cbd64a24f3ebd52a1f11a21240f55c0777cbc5b9e61c0c9b708edf6b90d5571f04\"
        }
    }
"""

        let ddo = try! JSONDecoder().decode(DecentralizedDocumentObject.self, from: jsonString.data(using: .utf8)!)

        let verifier = DDOVerifier.createDefault()

        XCTAssertTrue(try! verifier.verify(ddo))
    }
}
