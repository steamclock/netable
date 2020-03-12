//
//  NetableLoggingDestination.swift
//  Netable
//
//  Created by Brendan on 2020-03-12.
//  Copyright © 2020 Steamclock Software. All rights reserved.
//

import Foundation

public struct NetableLogEvent {
    public struct RequestStarted {
        let urlString: String
        let method: HTTPMethod
        let headers: [String: Any]
        let params: [String: Any]?
    }

    public struct RequestCompleted {
        let statusCode: Int
        let message: String
        let responseData: Data?
        let finalizedResult: Any?
    }

    public struct RequestFailed {
        let error: NetableError
    }
}

public protocol NetableLoggingDestination {
    func log(message: String)
    func log(requestStarted log: NetableLogEvent.RequestStarted)
    func log(requestCompleted log: NetableLogEvent.RequestCompleted)
    func log(requestFailed log: NetableLogEvent.RequestFailed)
}

// Declaring a default implementation here means that all protocol methods are optional
extension NetableLoggingDestination {
    func log(message: String) {}
    func log(requestStarted log: NetableLogEvent.RequestStarted) {}
    func log(requestCompleted log: NetableLogEvent.RequestCompleted) {}
    func log(requestFailed log: NetableLogEvent.RequestFailed) {}
}

public final class NetableLog: NetableLoggingDestination {
    public init() {}

    public func log(message: String) {
        debugPrint(message)
    }

    public func log(requestStarted log: NetableLogEvent.RequestStarted) {
        debugPrint("\(log.method.rawValue) Request Started:")
        debugPrint("    URL: \(log.urlString)")
        debugPrint("    Headers: \(log.headers)")
        if let params = log.params {
            debugPrint("    Parameters: \(params)")
        }
    }

    public func log(requestCompleted log: NetableLogEvent.RequestCompleted) {
        debugPrint("Request Completed:")
        debugPrint("    Status Code: \(log.statusCode)")

        if let data = log.responseData {
            debugPrint("    Data: \(data)")
        }

        if let finalizedData = log.finalizedResult {
            debugPrint("    Finalized Result: \(finalizedData)")
        }
    }

    public func log(requestFailed log: NetableLogEvent.RequestFailed) {
        debugPrint("[NETABLE]")
    }
}
