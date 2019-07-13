/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import Foundation
import IrohaCrypto

extension DecentralizedDocumentObject {
    public func authenticablePublicKey(for publicKey: Data) -> DDOPublicKey? {
        let publicKeyHex = (publicKey as NSData).toHexString()

        let optionalPublicKey = self.publicKey.first { $0.publicKey == publicKeyHex }

        guard let ddoPublicKey = optionalPublicKey else {
            return nil
        }

        if self.authentication.contains(where: { $0.publicKey == ddoPublicKey.pubKeyId }) {
            return ddoPublicKey
        } else {
            return nil
        }
    }
}
