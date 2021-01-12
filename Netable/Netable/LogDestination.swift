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
    public struct RequestInfo {
        public let urlString: String
        public let method: HTTPMethod
        public let headers: [String: Any]
        public let params: [String: Any]?
    }

    /// Print up some debugging info at start.
    case startupInfo(baseURL: URL, logDestination: LogDestination)

    /// A generic message, not tied to request state.
    case message(StaticString)

    /// Request has failed prior to sucessfully starting a network task for the request
    case requestCreationFailed(urlString: String, error: NetableError)

    /// Request has been successfully initiated.
    case requestStarted(request: RequestInfo)

    /// Request has successfully completed.
    /// Note: taskTime only covers the time it took the current network request to run, in retry scenarios the time for the whole request may be longer.
    case requestSuccess(request: RequestInfo, taskTime: TimeInterval, statusCode: Int, responseData: Data?, finalizedResult: Any)

    /// Sent when a request fails but will be retried. Note: taskTime only cover the time it took the current network request to run, in retry scenarios the time for the whole request may be longer.
    case requestRetrying(request: RequestInfo, taskTime: TimeInterval, error: NetableError)

    /// Sent when a request fails (and all retries have been compelted, if retries are enabled)
    case requestFailed(request: RequestInfo, taskTime: TimeInterval, error: NetableError)

    /// Default overrides, used by the default logging destination.
    public var debugDescription: String {
        switch self {
        case .startupInfo(let baseURL, let logDestination):
            return "Netable instance initiated. Here we go! Base URL: \(baseURL.absoluteString). Log Destination: \(logDestination)"
        case .message(let message):
            return message.description
        case .requestCreationFailed(let urlString, let error):
            return "Request (\(urlString)) failed: \(error.localizedDescription)"
        case .requestStarted(let request):
            return "Started \(request.method.rawValue) request... URL: \(request.urlString) Headers: \(request.headers) Params: \(request.params ?? [:])"
        case .requestSuccess(let request, _, let statusCode, let responseData, let finalizedResult):
            return "Request (\(request.urlString)) completed with status code \(statusCode) Data: \(responseData ?? Data()) Finalized data: \(String(describing: finalizedResult))"
        case .requestRetrying(let request, _, let error):
            return "Request (\(request.urlString)) retrying: \(error.localizedDescription)"
        case .requestFailed(let request, _, let error):
            switch error {
            case .httpError(let statusCode, let data):
                return "Request (\(request.urlString)) failed with status code \(statusCode) Data: \(data ?? Data())"
            default:
                return "Request (\(request.urlString)) failed: \(error.localizedDescription)"
            }
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
