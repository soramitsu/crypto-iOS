/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import Foundation

extension DARequestSignerProtocol {
    public func sign(urlRequest: URLRequest) throws -> URLRequest {
        var mutableURLRequest = urlRequest

        guard let daRequest = urlRequest.toDecentralizedAuthRequest() else {
            throw DARequestSignerError.invalidURLRequest
        }

        let signedRequest = try sign(request: daRequest)

        mutableURLRequest.appendDecentralizedAuthSignature(from: signedRequest)

        return mutableURLRequest
    }
}
