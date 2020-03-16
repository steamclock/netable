//
//  CustomLogDestination.swift
//  NetableExample
//
//  Created by Brendan on 2020-03-13.
//  Copyright © 2020 Steamclock Software. All rights reserved.
//

import Foundation
import Netable
import os

class CustomLogDestination: LogDestination {
    func log(event: LogEvent) {
        switch event {
        case .requestFailed(let error):
            os_log("Request failed: %s", error.localizedDescription)
        default:
            // Don't log anything except failed requests
            break
        }
    }
}
