//
//  SampleGETJSON.swift
//  NetableExample
//
//  Created by Brendan on 2020-03-19.
//  Copyright © 2020 Steamclock Software. All rights reserved.
//

import Netable

struct SampleResponse: Decodable {
    struct User: Decodable {
        let email: String
        let firstName: String
        let lastName: String
    }

    let data: User
}

struct SampleGetJSON: Request {
    typealias Parameters = [String: String]
    typealias RawResource = SampleResponse

    var method: HTTPMethod { return .get }

    var path: String {
        return "api/users/2"
    }

    var parameters: [String : String]
    
    var jsonKeyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .convertFromSnakeCase
}
