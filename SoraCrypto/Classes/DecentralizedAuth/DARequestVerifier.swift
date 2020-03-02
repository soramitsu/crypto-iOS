/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import Foundation
import IrohaCrypto

public protocol DARequestVerifierProtocol {
    func verify(signedRequest: DASignedRequest, publicKey: Data) -> Bool
}

public class DARequestVerifier: DARequestVerifierProtocol {
    private(set) var rawVerifier: IRSignatureVerifierProtocol

    public init(rawVerifier: IRSignatureVerifierProtocol) {
        self.rawVerifier = rawVerifier
    }

    public func verify(signedRequest: DASignedRequest, publicKey: Data) -> Bool {
        let optionalData = DASignatureDataHelper.createFrom(decentralizedId: signedRequest.decentralizedId,
                                                            publicKeyId: signedRequest.publicKeyId,
                                                            timestamp: signedRequest.timestamp,
                                                            request: signedRequest.request)

        guard let originalData = optionalData else {
            return false
        }

        guard let signature = try? IRIrohaSignature(rawData: signedRequest.signature) else {
            return false
        }

        guard let publicKey = try? IRIrohaPublicKey(rawData: publicKey) else {
            return false
        }

        return rawVerifier.verify(signature,
                                  forOriginalData: originalData,
                                  usingPublicKey: publicKey)
    }
}
