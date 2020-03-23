//
//  NetableLoggingDestination.swift
//  Netable
//
//  Created by Brendan on 2020-03-12.
//  Copyright © 2020 Steamclock Software. All rights reserved.
//

import Foundation

/// Wrapper class for log events emitted by Netable.
public enum LogEvent: CustomDebugStringConvertible {
    /// A generic message, not tied to request state.
    case message(String)

    /// Request has been successfully initiated.
    case requestStarted(urlString: String, method: HTTPMethod, headers: [String: Any], params: [String: Any]?)

    /// Request has completed, this will be send regardless of the HTTP status code.
    case requestCompleted(statusCode: Int, responseData: Data?, finalizedResult: Any?)

    /// Sent when a request fails for any reason.
    case requestFailed(error: NetableError)

    /// Default overrides, used by the default logging destination.
    public var debugDescription: String {
        switch self {
        case .message(let message): return message
        case .requestStarted(let urlString, let method, let headers, let params):
            return """
                Started \(method.rawValue) request...
                    URL: \(urlString)
                    Headers: \(headers)
                    Params: \(params ?? [:])
            """
        case .requestCompleted(let statusCode, let responseData, let finalizedResult):
            return """
                Request completed with status code \(statusCode)
                    Data: \(responseData ?? Data())
                    Finalized data: \(String(describing: finalizedResult))
            """
        case .requestFailed(let error):
            return "Request failed: \(error.localizedDescription)"
        }
    }
}

/// Conform to `LogDestination` to receive and handle log events emitted by Netable.
public protocol LogDestination {
    /**
     * Log an event emitted by the Netable client.
     *
     * - Parameter event: The event to log.
     */
    func log(event: LogEvent)
}

/// A default log destination that will print all messages using `debugPrint()`
public final class DefaultLogDestination: LogDestination {
    public init() {}

    /*
     * Log an event using `debugPrint`
     *
     * - Parameter event: The event to log.
     */
    public func log(event: LogEvent) {
        debugPrint(event.debugDescription)
    }
}

/// Log Destination that does not print anywhere.
public final class EmptyLogDestination: LogDestination {
    public init() {}

    public func log(event: LogEvent) {
        // This page left intentionally blank
    }
}
