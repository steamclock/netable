//
//  AdaptedRequest.swift
//  Netable
//
//  Created by Brendan Lensink on 2023-06-09.
//  Copyright © 2023 Steamclock Software. All rights reserved.
//

import Foundation

/// Container for the result of `Interceptor.adapt`.
public enum AdaptedRequest: Sendable {
    /// The original URLRequest was modified and the new result should be used instead.
    case changed(URLRequest)

    /// The original request should be switched out for a local file resource.
    case mocked(URL)

    /// The original request was not modified in any way.
    case notChanged
}
