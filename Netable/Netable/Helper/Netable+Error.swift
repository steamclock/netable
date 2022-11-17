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
     * Helper function that attempts to transform an error by:
     *    1. Checking of the error code is `NSURLErrorCancelled` or `NSURLErrorTimedOut` and transforming it to `NetableError.cancelled`
     *    2. Attempts to unwrap the error as a `NetableError`
     *    3. Wrap the error and return as `NetableError.unknownError`
     */
    var netableError: NetableError {
        let nsError = self as NSError
        if nsError.domain == NSURLErrorDomain &&
                nsError.code == NSURLErrorCancelled || nsError.code == NSURLErrorTimedOut {
            return NetableError.cancelled(self)
        }

        let netableError = (self as? NetableError) ?? NetableError.unknownError(self)
        return netableError
    }
}
