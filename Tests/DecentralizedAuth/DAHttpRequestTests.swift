/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import XCTest
import SoraCrypto

class DAHttpRequestTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDAHttpRequestToURLRequest() {
        // given
        guard let uri = URL(string: "http://google.com") else {
            XCTFail()
            return
        }

        guard let testBytes = RandomGenerator().generate(size: 32) else {
            XCTFail()
            return
        }

        let testData = Data(testBytes)

        let daRequest = DAHttpRequest(uri: uri, method: "GET", body: testData)

        // when
        let urlRequest = URLRequest(daRequest: daRequest)

        // then
        XCTAssertEqual(urlRequest.url, daRequest.uri)
        XCTAssertEqual(urlRequest.httpMethod, daRequest.method)
        XCTAssertEqual(urlRequest.httpBody, daRequest.body)

        // when
        let convertedRequest = urlRequest.toDecentralizedAuthRequest()

        XCTAssertEqual(daRequest, convertedRequest)
    }
}
