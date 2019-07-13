/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import Foundation
import SoraDocuments

enum DocumentOneCoderError: Error {
    case utf8ConversionFailed
}

public class DocumentOneCoder: DocumentNodeEncoderProtocol {
    private struct Constants {
        static let arrayBegin = "l"
        static let arrayEnd = "e"
        static let dictionaryBegin = "d"
        static let dictionaryEnd = "e"
        static let numberBegin = "i"
        static let numberEnd = "e"
        static let stringComponentsSeparator = ":"
    }

    private var encodedString: String!

    public init() {}

    public func encode(_ node: DocumentNodeProtocol) throws -> Data {
        encodedString = String()

        visit(node: node)

        guard let data = encodedString.data(using: .utf8) else {
            throw DocumentOneCoderError.utf8ConversionFailed
        }

        return data
    }
}

extension DocumentOneCoder: DocumentNodeVisitorProtocol {
    public func visit(value: Int) {
        encodedString.append(Constants.numberBegin)
        encodedString.append("\(value)")
        encodedString.append(Constants.numberEnd)
    }

    public func visit(value: String) {
        encodedString.append("\(value.lengthOfBytes(using: .utf8))")
        encodedString.append(Constants.stringComponentsSeparator)
        encodedString.append(value)
    }

    public func visit(node: DocumentNodeProtocol) {
        encodedString.append(Constants.dictionaryBegin)

        let keys = node.allKeys().sorted()

        for key in keys {
            visit(value: key)
            node.accept(visitor: self, for: key)
        }

        encodedString.append(Constants.dictionaryEnd)
    }

    public func visit(list: [DocumentNodeProtocol]) {
        encodedString.append(Constants.arrayBegin)

        for node in list {
            visit(node: node)
        }

        encodedString.append(Constants.arrayEnd)
    }

    public func visit(reference: DocumentReferenceProtocol) {
        visit(value: reference.referenceName)
    }
}
