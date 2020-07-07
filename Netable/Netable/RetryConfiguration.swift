//
//  RetryConfiguration.swift
//  Netable
//
//  Created by Nigel Brooke on 2020-06-30.
//  Copyright © 2020 Steamclock Software. All rights reserved.
//

import Foundation

public struct RetryConfiguration {
    /// Specify types of networking errors to retry
    public enum Errors {
        /// No retries will happen
        case none

        /// Retry all errors that occur as part of a attempted network request, including network failures and all non-200 HTTP responses (failures like malformed URLs, as well as intentional cancellations, and network timeouts will still not be retried)
        case all

        /// Retry any physical networking errors, other than timeouts
        case transport

        /// Test the errors with a user supplied closure. Custom errors are limited in the same way that ".all" is, there are certain types of errors (request formatting errors, cancellation, network timeouts) that this will NOT be called for and there is no option to retry. Note: will be called on a background thread so closure must be thread safe
        case custom(retryTest: (NetableError) -> Bool)

        internal func shouldRetry(_ error: NetableError) -> Bool {
            switch self {
            case .none:
                return false
            case .all:
                return true
            case .transport:
                switch error {
                case .requestFailed:
                    return true
                default:
                    return false
                }
            case .custom(let test):
                return test(error)
            }
        }
    }

    /// Which networking errors should be retried
    public let errors: Errors

    /// How many times to rety before giving up and failing for good
    public let count: UInt

    /// Delay time between retry attempts
    public let delay: TimeInterval

    public init(errors: Errors = .transport, count: UInt = 2, delay: TimeInterval = 5.0 ) {
        self.errors = errors
        self.count = count
        self.delay = delay
    }

    internal var enabled: Bool {
        switch errors {
        case .none:
            return false
        default:
            return count > 0
        }
    }
}
