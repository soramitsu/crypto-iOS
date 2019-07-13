/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import Foundation

public struct DAHttpRequestHeaderKeys {
    public static let timestamp = "SORA-AUTH-TIMESTAMP"
    public static let authId = "SORA-AUTH-ID"
    public static let publicKey = "SORA-AUTH-PUBLIC-KEY"
    public static let signature = "SORA-AUTH-SIGNATURE"
}

extension URLRequest {
    public init(daRequest: DAHttpRequest) {
        self.init(url: daRequest.uri)

        httpMethod = daRequest.method
        httpBody = daRequest.body
    }

    public init(daSignedRequest: DASignedRequest) {
        self.init(daRequest: daSignedRequest.request)

        appendDecentralizedAuthSignature(from: daSignedRequest)
    }

    public mutating func appendDecentralizedAuthSignature(from request: DASignedRequest) {
        addValue(String(request.timestamp), forHTTPHeaderField: DAHttpRequestHeaderKeys.timestamp)
        addValue(request.decentralizedId, forHTTPHeaderField: DAHttpRequestHeaderKeys.authId)
        addValue(request.publicKeyId, forHTTPHeaderField: DAHttpRequestHeaderKeys.publicKey)
        addValue(request.signature.base64EncodedString(), forHTTPHeaderField: DAHttpRequestHeaderKeys.signature)
    }

    public func toDecentralizedAuthRequest() -> DAHttpRequest? {
        guard let daUri = url else {
            return nil
        }

        let daMethod = httpMethod ?? "GET"

        return DAHttpRequest(uri: daUri, method: daMethod, body: httpBody)
    }
}
