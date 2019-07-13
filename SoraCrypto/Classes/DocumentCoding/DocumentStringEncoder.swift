/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import Foundation
import IrohaCrypto

public enum DocumentStringCoderError: Error {
    case invalidStringToDateFormat
    case invalidStringEncoding
}

public class DocumentStringCoder {
    private lazy var dateFormatter = DateFormatter.iso8601DateAndTimeFormatter()

    public init() {}
}

extension DocumentStringCoder: DocumentStringCoderProtocol {
    public func encode(_ data: Data) throws -> String {
        return data.toHexString()
    }

    public func encode(_ date: Date) throws -> String {
        return dateFormatter.string(from: date)
    }

    public func decodeData(_ string: String) throws -> Data {
        guard let data = Data(hexString: string) else {
            throw DocumentStringCoderError.invalidStringEncoding
        }

        return data
    }

    public func decodeDate(_ string: String) throws -> Date {
        guard let date = dateFormatter.date(from: string) else {
            throw DocumentStringCoderError.invalidStringToDateFormat
        }

        return date
    }
}
