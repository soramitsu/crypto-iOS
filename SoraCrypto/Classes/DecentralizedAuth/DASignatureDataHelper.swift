/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import Foundation

public class DASignatureDataHelper {
    public static func createFrom(decentralizedId: String, publicKeyId: String,
                                  timestamp: Int64, request: DAHttpRequest) -> Data? {
        let metaString = String(timestamp) + decentralizedId + publicKeyId

        guard let metaData = metaString.data(using: .utf8) else {
            return nil
        }

        guard let methodData = request.method.data(using: .utf8) else {
            return nil
        }

        guard let uriData = request.uri.absoluteString.data(using: .utf8) else {
            return nil
        }

        var resultData = methodData + uriData

        if let body = request.body {
            resultData += body
        }

        resultData += metaData

        return resultData
    }
}
