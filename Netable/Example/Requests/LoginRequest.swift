//
//  LoginRequest.swift
//  Example
//
//  Created by Amy Oulton on 2022-11-28.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation
import Netable

struct LoginParameters: Encodable {
    let email: String
    let password: String
}

struct LoginToken: Codable {
    let token: String
}

struct LoginRequest: Request {
    typealias Parameters = LoginParameters
    typealias RawResource = LoginToken

    var method: HTTPMethod { return .get }

    var path = "user/login"

    var parameters: LoginParameters

    var unredactedParameterKeys: Set<String> {
        ["email"]
    }
}
