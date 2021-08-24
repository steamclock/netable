//
//  Config.swift
//  Netable
//
//  Created by Brendan on 2021-08-20.
//  Copyright © 2021 Steamclock Software. All rights reserved.
//

import Foundation

public struct Config {
    var disableLogRedaction: Bool
    var timeout: TimeInterval?

    public init(disableLogRedaction: Bool = false, timeout: TimeInterval? = nil) {
        self.disableLogRedaction = disableLogRedaction
        self.timeout = timeout
    }
}
