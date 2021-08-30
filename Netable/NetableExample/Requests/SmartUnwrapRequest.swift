//
//  SmartUnwrapRequest.swift
//  NetableExample
//
//  Created by Brendan on 2021-08-27.
//  Copyright © 2021 Steamclock Software. All rights reserved.
//

import Netable

struct User: Decodable {
    let username: String
    let firstName: String
    let password: String
}

struct SmartUnwrapRequest: Request {
    typealias Parameters = LoginParams
    typealias RawResource = SmartUnwrap<User>
    typealias FinalResource = User

    public var smartUnwrapKey: String? {
        return "json"
    }

    public var method: HTTPMethod { return .post }
    public var jsonKeyEncodingStrategy: JSONEncoder.KeyEncodingStrategy {
        return .convertToSnakeCase
    }

    public var path: String {
        return "/post"
    }

    public var parameters: LoginParams

    public var unredactedParameterKeys: Set<String> {
        ["first_name", "username"]
    }
}
