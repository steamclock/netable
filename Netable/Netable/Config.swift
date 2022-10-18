//
//  Config.swift
//  Netable
//
//  Created by Brendan on 2021-08-20.
//  Copyright © 2021 Steamclock Software. All rights reserved.
//

import Foundation

public struct Config {
    /// Enable redaction of parameter values in logs. Defaults to true.
    let enableLogRedaction: Bool

    /// Headers to be sent with each request.
    public let globalHeaders: [String: String]

    /// Decoding strategy to use when decoding keys from JSON. Default is `useDefaultKeys`. Note this value can be overridden by individual `Request`s.
    let jsonDecodingStrategy: JSONDecoder.KeyDecodingStrategy

    /// Encoding strategy to use when encoding keys to JSON. Default is `useDefaultKeys`. Note this value can be overridden by individual `Request`s.
    let jsonEncodingStrategy: JSONEncoder.KeyEncodingStrategy

    /// Timeout interval for requests. Default is `nil`. This value is assigned to `URLSessionConfiguration.timeoutIntervalForRequest`.
    let timeout: TimeInterval?

    /**
     * Create a new `Config` to pass into a Netable instance
     *
     * - parameters:
     *      - enableLogRedaction:
     *      - jsonDecodingStrategy: The default strategy to use when decoding JSON. Default is .useDefaultKeys
     *      - jsonEncodingStrategy:
     *      - timeout:
     */
    public init(
            enableLogRedaction: Bool = true,
            globalHeaders: [String: String] = [:],
            jsonDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
            jsonEncodingStrategy: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys,
            timeout: TimeInterval? = nil) {
        self.enableLogRedaction = enableLogRedaction
        self.globalHeaders = globalHeaders
        self.jsonDecodingStrategy = jsonDecodingStrategy
        self.jsonEncodingStrategy = jsonEncodingStrategy
        self.timeout = timeout
    }
}
