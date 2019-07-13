/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import Foundation
import IrohaCrypto

extension DDOVerifier {
    public static func createDefault() -> DDOVerifier {
        return DDOVerifier()
            .with(encoder: DocumentOneCoder())
            .with(stringCoder: DocumentStringCoder())
            .with(signatureVerifier: IREd25519Sha512Verifier())
    }
}
