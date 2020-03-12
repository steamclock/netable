//
//  NetableLoggingDestination.swift
//  Netable
//
//  Created by Brendan on 2020-03-12.
//  Copyright © 2020 Steamclock Software. All rights reserved.
//

import Foundation

public enum NetableLogLevel {
    case verbose
    case debug
    case warn
}

public protocol NetableLoggingDestination {
    func log(_ info: String, severity: NetableLogLevel)
}

public class NetableLog: NetableLoggingDestination {
    public init() {}
    
    public func log(_ info: String, severity: NetableLogLevel) {
        debugPrint("[NETABLE] " + info)
    }
}
