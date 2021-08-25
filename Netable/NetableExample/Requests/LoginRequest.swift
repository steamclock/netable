//
//  LoginRequest.swift
//  NetableExample
//
//  Created by Brendan on 2020-03-16.
//  Copyright © 2020 Steamclock Software. All rights reserved.
//

import Netable

struct LoginParams: Encodable {
    let username: String
    let password: String
    let firstName: String
}

struct LoginResponse: Decodable {
    let url: String
}

struct LoginRequest: Request {
    typealias Parameters = LoginParams
    typealias RawResource = LoginResponse

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
