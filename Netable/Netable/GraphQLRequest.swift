//
//  GraphQLRequest.swift
//  Netable
//
//  Created by Brendan on 2022-09-12.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation

public protocol GraphQLRequest: Request {
    associatedtype Parameters = [String: String]
}

public extension GraphQLRequest {
    var method: HTTPMethod { HTTPMethod.post }

    var path: String { "index/" }

    var parameters: [String: String] {
        let params = try! String(contentsOfFile: Bundle.main.path(forResource: String("\(type(of: self))".split(separator: ".").last!), ofType: "graphql")!)
        return ["query": params]
    }
}
