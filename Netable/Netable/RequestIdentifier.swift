//
//  RequestIdentifier.swift
//  Netable
//
//  Created by Brendan on 2020-04-03.
//  Copyright © 2020 Steamclock Software. All rights reserved.
//

import Foundation

/// Wrapper for `taskIdentifier` used to manage active requests.
public struct RequestIdentifier {
    /// Task id assigned by the URLSession for a request.
    let id: Int
}
