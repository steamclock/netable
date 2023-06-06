//
//  Interceptor.swift
//  Netable
//
//  Created by Brendan Lensink on 2023-06-06.
//  Copyright © 2023 Steamclock Software. All rights reserved.
//


import Foundation

public struct Interceptor: Sendable {
    let interceptors: [RequestInterceptor]

    public init(_ interceptors: [RequestInterceptor]) {
        self.interceptors = interceptors
    }

    public init(_ interceptor: RequestInterceptor) {
        self.interceptors = [interceptor]
    }

    public func applyInterceptors(request: URLRequest, instance: Netable) async throws -> AdaptedRequest {
        var adaptedURLRequest: URLRequest?

        for interceptor in interceptors {
            let result = try await interceptor.adapt(adaptedURLRequest ?? request, instance: instance)
            switch result {
            case .changed(let newResult): adaptedURLRequest = newResult
            case .mocked(let mockedUrl): return AdaptedRequest.mocked(mockedUrl)
            case .notChanged: continue
            }
        }

        if let adapted = adaptedURLRequest {
            return AdaptedRequest.changed(adapted)
        }

        return .notChanged
    }
}

public enum AdaptedRequest {
    case changed(URLRequest)
    case mocked(URL)
    case notChanged
}

public protocol RequestInterceptor: Sendable {
    func adapt(_ request: URLRequest, instance: Netable) async throws -> AdaptedRequest
}
