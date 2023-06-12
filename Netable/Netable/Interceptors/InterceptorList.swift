//
//  Interceptor.swift
//  Netable
//
//  Created by Brendan Lensink on 2023-06-06.
//  Copyright © 2023 Steamclock Software. All rights reserved.
//


import Foundation

/// Container struct for interceptors.
public struct InterceptorList: Sendable {
    let interceptors: [Interceptor]

    /**
     * Create a new interceptor list with a set of interceptors.
     *
     * - parameter interceptors: The interceptors that will be applied to each request.
     */
    public init(_ interceptors: [Interceptor]) {
        self.interceptors = interceptors
    }

    /**
     * Create a new interceptor list with a single interceptor.
     *
     * - parameter interceptor: The interceptor that will be applied to each request.
     */
    public init(_ interceptor: Interceptor) {
        self.interceptors = [interceptor]
    }

    /**
     * Apply all intereceptors to the given request.
     * Interceptors are applied in the order they were passed into the `InterceptorList` constructor,
     * except unless a mocked result is found, it will return immedediately.
     *
     * - parameter request: The request to apply interceptors to.
     * - parameter instance: A reference to the Netable instance that is applying these interceptors.
     */
    public func applyInterceptors(request: URLRequest, instance: Netable) async throws -> AdaptedRequest {
        var adaptedURLRequest: URLRequest?

        for interceptor in interceptors {
            let result = try await interceptor.adapt(adaptedURLRequest ?? request, instance: instance)
            switch result {
            case .changed(let newResult):
                adaptedURLRequest = newResult
            case .mocked(let mockedUrl):
                if !mockedUrl.isFileURL {
                    throw NetableError.interceptorError("Only file URLs are supported for mocking URLs")
                }

                return AdaptedRequest.mocked(mockedUrl)
            case .notChanged: continue
            }
        }

        if let adapted = adaptedURLRequest {
            return AdaptedRequest.changed(adapted)
        }

        return .notChanged
    }

    /**
     * Check if a `URL` starts with 'https://' to determine if it's a remote URL or not.
     *
     * - parameter url: The URL to check.
     */
    private func isRemote(_ url: URL) -> Bool {
        return url.absoluteString.contains("https://")
    }
}
