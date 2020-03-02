/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import Foundation
import IrohaCrypto

extension Data {
    public init?(hexString: String) {
        guard let data = try? NSData(hexString: hexString) as Data else {
            return nil
        }

        self = data
    }

    public func toHexString() -> String {
        return (self as NSData).toHexString()
    }
}
