/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import XCTest
import SoraCrypto

class DDOOperationsTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAuthenticationOpportunity() {
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

        guard let publicKeyData = Data(hexString: publicKey.publicKey) else {
            XCTFail()
            return
        }

        XCTAssertEqual(ddo.authenticablePublicKey(for: publicKeyData)?.pubKeyId, publicKey.pubKeyId)

        guard let nonceData = Data(hexString: proof.nonce) else {
            XCTFail()
            return
        }

        XCTAssertNil(ddo.authenticablePublicKey(for: nonceData))
    }

}
