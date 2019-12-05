//
//  Log.swift
//  SCNetworkAPIMobile
//
//  Created by Brendan on 2019-12-03.
//

import Foundation

internal var log = Log()

public enum NetworkLogLevel: Int {
    case info
    case error
    case none

    var name: String {
        switch self {
        case .info: return "info"
        case .error: return "error"
        case .none: return "none"
        }
    }
}

class Log {
    fileprivate init() {}

    var logLevel: NetworkLogLevel = .info

    func info(_ message: String) {
        if logLevel.rawValue >= NetworkLogLevel.info.rawValue {
            NSLog("NetworkAPI: " + message)
        }
    }

    func error(_ message: String) {
        if logLevel.rawValue >= NetworkLogLevel.error.rawValue {
            NSLog("NetworkAPI: " + message)
        }
    }
}
