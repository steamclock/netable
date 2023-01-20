//
//  ErrorService.swift
//  Example
//
//  Created by Amy Oulton on 2022-12-15.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Combine
import Foundation
import Netable

@MainActor
final class ErrorService {
    static let shared = ErrorService()

    let errors = PassthroughSubject<NetableError?, Never>()
}


extension ErrorService: RequestFailureDelegate {
    func requestDidFail<T>(_ request: T, error: NetableError) {
        if case let NetableError.httpError(statusCode, _) = error, statusCode == 401 {
            return
        }
        Task { @MainActor in
            errors.send(error)
        }
    }
}
