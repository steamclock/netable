//
//  Interceptor.swift
//  Netable
//
//  Created by Brendan Lensink on 2023-06-06.
//  Copyright © 2023 Steamclock Software. All rights reserved.
//


import Foundation

public struct InterceptorList: Sendable {
    let interceptors: [Interceptor]

    public init(_ interceptors: [Interceptor]) {
        self.interceptors = interceptors
    }

    public init(_ interceptor: Interceptor) {
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

public enum AdaptedRequest: Sendable {
    case changed(URLRequest)
    case mocked(URL)
    case notChanged
}

public protocol Interceptor: Sendable {
    func adapt(_ request: URLRequest, instance: Netable) async throws -> AdaptedRequest
}
