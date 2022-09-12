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

    func getGraphQLQueryFileContents() -> String
}

public extension GraphQLRequest {
    var method: HTTPMethod { HTTPMethod.post }

    var path: String { "" }

    func getGraphQLQueryFileContents() -> String {
        guard let resource = "\(type(of: self))".split(separator: ".").last,
            let resourcePath = Bundle.main.path(forResource: String(resource), ofType: "graphql"),
            let params = try? String(contentsOfFile: resourcePath) else {
            fatalError("Failed to retrieve .graphql file for request: \(type(of: self)).")
        }

        return params
    }
}

