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
    var enableLogRedaction: Bool

    /// Decoding strategy to use when decoding keys from JSON. Default is `useDefaultKeys`. Note this value can be overridden by individual `Request`s.
    let jsonDecodingStrategy: JSONDecoder.KeyDecodingStrategy

    /// Encoding strategy to use when encoding keys to JSON. Default is `useDefaultKeys`. Note this value can be overridden by individual `Request`s.
    let jsonEncodingStrategy: JSONEncoder.KeyEncodingStrategy

    /// Timeout interval for requests. Default is `nil`. This value is assigned to `URLSessionConfiguration.timeoutIntervalForRequest`.
    let timeout: TimeInterval?

    public init(
            enableLogRedaction: Bool = true,
            jsonDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
            jsonEncodingStrategy: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys,
            timeout: TimeInterval? = nil) {
        self.enableLogRedaction = enableLogRedaction
        self.jsonDecodingStrategy = jsonDecodingStrategy
        self.jsonEncodingStrategy = jsonEncodingStrategy
        self.timeout = timeout
    }
}
