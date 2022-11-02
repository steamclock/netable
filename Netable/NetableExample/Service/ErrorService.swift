//
//  ErrorService.swift
//  NetableExample
//
//  Created by Brendan on 2022-11-02.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Combine
import Foundation
import Netable

class ErrorService {
    static var shared = ErrorService()

    var errors = PassthroughSubject<NetableError, Never>()
}

extension ErrorService: RequestFailureDelegate {
    func requestDidFail<T>(_ request: T, error: NetableError) {
        errors.send(error)
    }
}
