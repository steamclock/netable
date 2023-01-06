//
//  RequestFailedDelegate.swift
//  Netable
//
//  Created by Brendan on 2021-08-24.
//  Copyright © 2021 Steamclock Software. All rights reserved.
//

import Foundation

public protocol RequestFailureDelegate {
    func requestDidFail<T: Request>(_ request: T, error: NetableError)
}
