//
//  Interceptor.swift
//  Netable
//
//  Created by Brendan Lensink on 2023-06-09.
//  Copyright © 2023 Steamclock Software. All rights reserved.
//

import Foundation

/**
 *  Interceptors are applied to each request in the given `Netable` instance prior to performing the request.
 */
public protocol Interceptor: Sendable {
    /**
     * Adapts the provided URLRequest, returning a modified copy changed in one of three potentional ways:
     * - No changes are made, the request proceeds as normal.
     * - The request has been modified in some way before sending. How it has been modified is left to the user to determine.
     * - The request has been switched with a mocked resource JSON.
     *
     */
    func adapt(_ request: URLRequest, instance: Netable) async throws -> AdaptedRequest
}
