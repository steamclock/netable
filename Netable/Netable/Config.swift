//
//  Config.swift
//  Netable
//
//  Created by Brendan on 2021-08-20.
//  Copyright © 2021 Steamclock Software. All rights reserved.
//

import Foundation

public struct Config {
    var enableLogRedaction: Bool
    var timeout: TimeInterval?

    public init(enableLogRedaction: Bool = true, timeout: TimeInterval? = nil) {
        self.enableLogRedaction = enableLogRedaction
        self.timeout = timeout
    }
}
