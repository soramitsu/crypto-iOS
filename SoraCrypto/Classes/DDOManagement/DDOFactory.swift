/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import Foundation

public protocol DDOFactoryProtocol {
    func createDecentralizedIdFrom(username: String, domain: String) -> String
    func createPublicKeyIdFrom(username: String, domain: String, ddoIndex: Int) -> String
}

public class DDOFactory: DDOFactoryProtocol {
    public init() {}

    public func createDecentralizedIdFrom(username: String, domain: String) -> String {
        return "did:\(domain):\(username)"
    }

    public func createPublicKeyIdFrom(username: String, domain: String, ddoIndex: Int) -> String {
        return createDecentralizedIdFrom(username: username, domain: domain) + "#keys-\(ddoIndex)"
    }
}
