//
//  CustomLogDestination.swift
//  Example
//
//  Created by Amy Oulton on 2022-12-01.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation
import Netable
import os

/// Defines a custom log destination for Netable to send logs to.
final class CustomLogDestination: LogDestination {
    func log(event: LogEvent) {
        switch event {
        case .requestSuccess(_, _, _, _, _):
            debugPrint("Request successful!")
        default:
            debugPrint(event.debugDescription)
        }
    }
}
