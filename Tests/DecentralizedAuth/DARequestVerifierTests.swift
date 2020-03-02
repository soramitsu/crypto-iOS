/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import XCTest
import SoraCrypto
import IrohaCrypto

class DARequestVerifierTests: XCTestCase {
    var verifier = DARequestVerifier(rawVerifier: IRIrohaSignatureVerifier())

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testArbitraryPostRequestVerification() {
        // given
        guard let publicKey = Data(hexString: "e102764a0bf09c038e9c717aa47c45a68e16ca4b75a45326c0ae0fbc31678a63") else {
            XCTFail()
            return
        }

        guard let url = URL(string: "https://example.com/one/two/three?fizz=buzz&foo=bar#hi-there") else {
            XCTFail()
            return
        }

        guard let body = "param1=a&param2=b&param3=foobar".data(using: .utf8) else {
            XCTFail()
            return
        }

        let request = DAHttpRequest(uri: url, method: "POST", body: body)

        // when
        let signatureHex = "2301169c9082289d2c48890f67faf912608b4d2b91d8c7c7554f3cb26635559f19177be510f99da74e4af04b5ff20e7a51935e28ac13eccc86ad8648b3f6dd04"

        guard let signatureData = Data(hexString: signatureHex) else {
            XCTFail()
            return
        }

        let signedRequest = DASignedRequest(request: request,
                                            signature: signatureData,
                                            decentralizedId: "did:sora:uuid:caf4f7e3-401b-40de-9b1b-7498aeb618a8",
                                            publicKeyId: "did:sora:uuid:caf4f7e3-401b-40de-9b1b-7498aeb618a8#keys-1",
                                            timestamp: 1536229143376)

        // then
        XCTAssertTrue(verifier.verify(signedRequest: signedRequest, publicKey: publicKey))
    }

    func testGetRequestVerificationGeneratedBySigner() {
        // given
        guard
            let privateKey = Data(hexString: "e66f0a60d3f4c5c89abd4e9c3b848abad4b8fa0743773911be707a229ded1c66"),
            let publicKey = Data(hexString: "e102764a0bf09c038e9c717aa47c45a68e16ca4b75a45326c0ae0fbc31678a63") else {
                XCTFail()
                return
        }
        
        let rawSigner = createRawSignerWith(privateKey: privateKey)

        let signer = DARequestSigner()
            .with(decentralizedId: "did:sora:username")
            .with(publicKeyId: "did:sora:username#key-1")
            .with(rawSigner: rawSigner)

        guard let url = URL(string: "https://example.com/one/two/three?fizz=buzz&foo=bar#hi-there") else {
            XCTFail()
            return
        }

        let urlRequest = URLRequest(url: url)

        guard let daRequest = urlRequest.toDecentralizedAuthRequest() else {
            XCTFail()
            return
        }

        // when
        guard let signedRequest = try? signer.sign(request: daRequest) else {
            XCTFail()
            return
        }

        // then
        XCTAssertTrue(verifier.verify(signedRequest: signedRequest, publicKey: publicKey))
    }

    // MARK: Private

    func createRawSignerWith(privateKey: Data) -> IRSignatureCreatorProtocol {
        let privateKeyObject = try! IRIrohaPrivateKey(rawData: privateKey)
        return IRIrohaSigner(privateKey: privateKeyObject)
    }
}
