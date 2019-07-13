/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import Foundation
import SoraDocuments

public protocol DocumentNodeEncoderProtocol {
    func encode(_ node: DocumentNodeProtocol) throws -> Data
}

public protocol DocumentStringCoderProtocol {
    func encode(_ data: Data) throws -> String
    func encode(_ date: Date) throws -> String
    func decodeData(_ string: String) throws -> Data
    func decodeDate(_ string: String) throws -> Date
}
