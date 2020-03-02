/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import Foundation
import IrohaCrypto

public enum DARequestSignerError: Error {
    case invalidURLRequest
    case signingDataBuildingFailed
}

public protocol DARequestSignerProtocol {
    func with(rawSigner: IRSignatureCreatorProtocol) -> Self
    func with(decentralizedId: String) -> Self
    func with(publicKeyId: String) -> Self
    func with(timestamp: Int64) -> Self

    func sign(request: DAHttpRequest) throws -> DASignedRequest
}

public class DARequestSigner: DARequestSignerProtocol {
    public private(set) var rawSigner: IRSignatureCreatorProtocol!
    public private(set) var decentralizedId: String!
    public private(set) var publicKeyId: String!
    public private(set) var timestamp: Int64?

    public init() {}

    public func with(rawSigner: IRSignatureCreatorProtocol) -> Self {
        self.rawSigner = rawSigner
        return self
    }

    public func with(decentralizedId: String) -> Self {
        self.decentralizedId = decentralizedId
        return self
    }

    public func with(publicKeyId: String) -> Self {
        self.publicKeyId = publicKeyId
        return self
    }

    public func with(timestamp: Int64) -> Self {
        self.timestamp = timestamp
        return self
    }

    public func sign(request: DAHttpRequest) throws -> DASignedRequest {
        let created = timestamp ?? Int64(Date().timeIntervalSince1970 * 1000)

        let optionalDataToSign = DASignatureDataHelper.createFrom(decentralizedId: decentralizedId,
                                                                  publicKeyId: publicKeyId,
                                                                  timestamp: created,
                                                                  request: request)
        guard let dataToSign = optionalDataToSign else {
            throw DARequestSignerError.signingDataBuildingFailed
        }

        let signature = try rawSigner.sign(dataToSign)

        return DASignedRequest(request: request, signature: signature.rawData(), decentralizedId: decentralizedId,
                               publicKeyId: publicKeyId, timestamp: created)
    }
}
