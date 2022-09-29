//
//  Netable+Error.swift
//  Netable
//
//  Created by Brendan on 2022-09-29.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation

public extension Error {
    /**
     * Helper function that takes an error and tries to unwrap it to a NetableError.
     * If the unwrap fails, it will wrap the error in `NetableError.unknownError`.
     */
    var netableError: NetableError {
        let netableError = (self as? NetableError) ?? NetableError.unknownError(self)
        return netableError
    }
}
