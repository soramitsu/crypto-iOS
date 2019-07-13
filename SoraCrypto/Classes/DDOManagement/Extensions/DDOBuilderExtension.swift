/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import Foundation

import Foundation

extension DDOBuilder {
    public static func createDefault() -> DDOBuilder {
        return DDOBuilder()
            .with(encoder: DocumentOneCoder())
            .with(stringCoder: DocumentStringCoder())
            .with(randomGenerator: RandomGenerator())
    }
}
