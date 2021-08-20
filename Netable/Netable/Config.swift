//
//  Config.swift
//  Netable
//
//  Created by Brendan on 2021-08-20.
//  Copyright © 2021 Steamclock Software. All rights reserved.
//

import Foundation

public struct Config {
    /// Decoding strategy to use when decoding keys from JSON. Default is `useDefaultKeys`. Note this value can be overridden by individual `Request`s.
    let jsonDecodingStrategy: JSONDecoder.KeyDecodingStrategy

    /// Encoding strategy to use when encoding keys to JSON. Default is `useDefaultKeys`. Note this value can be overridden by individual `Request`s.
    let jsonEncodingStrategy: JSONEncoder.KeyEncodingStrategy

    /// Timeout interval for requests. Default is `nil`. This value is assigned to `URLSessionConfiguration.timeoutIntervalForRequest`.
    let timeout: TimeInterval?

    public init(
            jsonDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
            jsonEncodingStrategy: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys,
            timeout: TimeInterval? = nil) {
        self.timeout = timeout
        self.jsonDecodingStrategy = jsonDecodingStrategy
        self.jsonEncodingStrategy = jsonEncodingStrategy
    }

    internal var urlSession: URLSession {
        let urlSession = URLSession(configuration: .ephemeral)

        if let timeout = timeout {
            urlSession.configuration.timeoutIntervalForRequest = timeout
        }

        return urlSession
    }
}
