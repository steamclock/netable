//
//  LoginRequest.swift
//  NetableExample
//
//  Created by Brendan on 2021-09-03.
//

import Netable

struct LoginParams: Encodable {
    let email: String
    let password: String
}

struct LoginRequest: Request {
    typealias Parameters = LoginParams
    typealias RawResource = User

    var method = HTTPMethod.get

    var path = "login"

    var parameters: LoginParams
}
