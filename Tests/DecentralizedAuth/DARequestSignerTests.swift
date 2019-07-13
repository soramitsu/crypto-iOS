/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import XCTest
import SoraCrypto
import IrohaCrypto

class DARequestSignerTests: XCTestCase {
    var requestSigner: DARequestSigner!

    override func setUp() {
        super.setUp()

        requestSigner = DARequestSigner()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testArbitraryDARequestSigning() {
        // given
        guard let privateKey = Data(hexString: "e66f0a60d3f4c5c89abd4e9c3b848abad4b8fa0743773911be707a229ded1c66") else {
            XCTFail()
            return
        }

        let rawSigner = createRawSignerWith(privateKey: privateKey)

        let daSignatureCreator = DARequestSigner()
            .with(decentralizedId: "did:sora:uuid:caf4f7e3-401b-40de-9b1b-7498aeb618a8")
            .with(publicKeyId: "did:sora:uuid:caf4f7e3-401b-40de-9b1b-7498aeb618a8#keys-1")
            .with(timestamp: 1536229143376)
            .with(rawSigner: rawSigner)

        guard let url = URL(string: "https://example.com/one/two/three?fizz=buzz&foo=bar#hi-there") else {
            XCTFail()
            return
        }

        guard let body = "param1=a&param2=b&param3=foobar".data(using: .utf8) else {
            XCTFail()
            return
        }

        let daRequest = DAHttpRequest(uri: url, method: "POST", body: body)

        // when
        guard let daSignedRequest = try? daSignatureCreator.sign(request: daRequest) else {
            XCTFail()
            return
        }

        // then
        XCTAssertEqual(daSignedRequest.signature.base64EncodedString(),
                       "IwEWnJCCKJ0sSIkPZ/r5EmCLTSuR2MfHVU88smY1VZ8ZF3vlEPmdp05K8Etf8g56UZNeKKwT7MyGrYZIs/bdBA==")
    }

    func testArbitraryURLRequestSigning() {
        // given
        guard let privateKey = Data(hexString: "e66f0a60d3f4c5c89abd4e9c3b848abad4b8fa0743773911be707a229ded1c66") else {
            XCTFail()
            return
        }
        
        let rawSigner = createRawSignerWith(privateKey: privateKey)

        let daSignatureCreator = DARequestSigner()
            .with(decentralizedId: "did:sora:uuid:caf4f7e3-401b-40de-9b1b-7498aeb618a8")
            .with(publicKeyId: "did:sora:uuid:caf4f7e3-401b-40de-9b1b-7498aeb618a8#keys-1")
            .with(timestamp: 1536229143376)
            .with(rawSigner: rawSigner)

        guard let url = URL(string: "https://example.com/one/two/three?fizz=buzz&foo=bar#hi-there") else {
            XCTFail()
            return
        }

        let httpMethod = "POST"

        guard let body = "param1=a&param2=b&param3=foobar".data(using: .utf8) else {
            XCTFail()
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod
        urlRequest.httpBody = body

        // when
        guard let signedRequest = try? daSignatureCreator.sign(urlRequest: urlRequest) else {
            XCTFail()
            return
        }

        // then
        XCTAssertEqual(urlRequest.url, signedRequest.url)
        XCTAssertEqual(urlRequest.httpMethod, signedRequest.httpMethod)
        XCTAssertEqual(urlRequest.httpBody, signedRequest.httpBody)

        XCTAssertEqual(signedRequest.value(forHTTPHeaderField: DAHttpRequestHeaderKeys.signature),
                       "IwEWnJCCKJ0sSIkPZ/r5EmCLTSuR2MfHVU88smY1VZ8ZF3vlEPmdp05K8Etf8g56UZNeKKwT7MyGrYZIs/bdBA==")
        XCTAssertEqual(signedRequest.value(forHTTPHeaderField: DAHttpRequestHeaderKeys.publicKey),
                       daSignatureCreator.publicKeyId)
        XCTAssertEqual(signedRequest.value(forHTTPHeaderField: DAHttpRequestHeaderKeys.authId),
                       daSignatureCreator.decentralizedId)
        XCTAssertEqual(signedRequest.value(forHTTPHeaderField: DAHttpRequestHeaderKeys.timestamp),
                       String(daSignatureCreator.timestamp!))

    }

    // MARK: Private

    func createRawSignerWith(privateKey: Data) -> IRSignatureCreatorProtocol {
        let privateKeyObject = IREd25519PrivateKey(rawData: privateKey)!

        return IREd25519Sha512Signer(privateKey: privateKeyObject)!
    }
}
