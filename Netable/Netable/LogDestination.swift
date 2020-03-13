//
//  NetableLoggingDestination.swift
//  Netable
//
//  Created by Brendan on 2020-03-12.
//  Copyright © 2020 Steamclock Software. All rights reserved.
//

import Foundation

public enum LogEvent: CustomDebugStringConvertible {
    case message(String)
    case requestStarted(urlString: String, method: HTTPMethod, headers: [String: Any], params: [String: Any]?)
    case requestCompleted(statusCode: Int, responseData: Data?, finalizedResult: Any?)
    case requestFailed(error: NetableError)

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

public protocol LogDestination {
    func log(event: LogEvent)
}

public final class DefaultLogDestination: LogDestination {
    public init() {}

    public func log(event: LogEvent) {
        debugPrint(event.debugDescription)
    }
}

public final class EmptyLogDestination: LogDestination {
    public init() {}

    public func log(event: LogEvent) {
        // This page left intentionally blank
    }
}
