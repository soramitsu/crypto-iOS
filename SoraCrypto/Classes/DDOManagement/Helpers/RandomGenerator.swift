/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import Foundation

public protocol RandomGeneratorProtocol {
    func generate(size: Int) -> [UInt8]?
}

public class RandomGenerator: RandomGeneratorProtocol {
    public init() {}

    public func generate(size: Int) -> [UInt8]? {
        var bytes = [UInt8](repeating: 0, count: size)
        let result = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)

        if result != errSecSuccess {
            return nil
        }

        return bytes
    }
}
