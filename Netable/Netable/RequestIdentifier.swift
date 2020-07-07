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
    /// Unique task id to identify a request
    internal let id: String

    /// A reference to the Netable session that started the request.
    /// Keep track of this to prevent accidental misuse of `Netable.cancel`.
    internal weak var session: Netable?

    /*
     * Cancel an ongoing request without needing to store a reference to the `Netable` instance.
     */
    public func cancel() {
        session?.cancel(byId: self)
    }
}
