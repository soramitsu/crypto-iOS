/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import Foundation

public struct DAHttpRequest: Equatable, Hashable {
    public var uri: URL
    public var method: String
    public var body: Data?

    public init(uri: URL, method: String, body: Data?) {
        self.uri = uri
        self.method = method
        self.body = body
    }
}

public struct DASignedRequest: Equatable, Hashable {
    public var request: DAHttpRequest
    public var signature: Data
    public var decentralizedId: String
    public var publicKeyId: String
    public var timestamp: Int64

    public init(request: DAHttpRequest,
                signature: Data,
                decentralizedId: String,
                publicKeyId: String,
                timestamp: Int64) {
        self.request = request
        self.signature = signature
        self.decentralizedId = decentralizedId
        self.publicKeyId = publicKeyId
        self.timestamp = timestamp
    }
}
