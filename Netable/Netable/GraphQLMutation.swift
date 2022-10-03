//
//  GraphQLMutation.swift
//  Netable
//
//  Created by Brendan on 2022-09-12.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation

/// This protocol extends the default `Request` protocol, adding support for making GraphQL mutation requests.
public protocol GraphQLMutation: GraphQLRequest {
    /// Your mutation's input will be encoded and sent along with the request.
    associatedtype Input: Encodable

    var input: Input { get }
}

public extension GraphQLMutation {
    /// Encodes and combines the request `Input` and query to form the request.
    var parameters: [String: String] {
        let params = getGraphQLQueryContents()

        guard let encodedData = try? JSONEncoder().encode(input),
              let encodedInputs = String(data: encodedData, encoding: .utf8) else {
            fatalError("Failed to unwrap inputs for graphQL mutation: \(type(of: self))")
        }

        return ["query": params, "input": encodedInputs]
    }

    var unredactedParameterKeys: Set<String> {
        ["query"]
    }
}
