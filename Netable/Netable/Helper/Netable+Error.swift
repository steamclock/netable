//
//  Netable+Error.swift
//  Netable
//
//  Created by Brendan on 2022-09-29.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation

public extension Error {
    var netableError: NetableError {
        let netableError = (self as? NetableError) ?? NetableError.unknownError(self)
        return netableError
    }
}
