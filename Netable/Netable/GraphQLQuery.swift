//
//  GraphQLQuery.swift
//  Netable
//
//  Created by Brendan on 2022-09-12.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation

public protocol GraphQLQuery: GraphQLRequest {
    associatedtype Input: Encodable

    var input: Input? { get }
}

public extension GraphQLQuery {
    var parameters: [String: String] {
        let params = getGraphQLQueryContents()

        guard let input = input else {
            return ["query": params]
        }

        guard let encodedData = try? JSONEncoder().encode(input),
              let encodedInputs = String(data: encodedData, encoding: .utf8) else {
            fatalError("Failed to unwrap inputs for graphQL mutation: \(type(of: self))")
        }

        return ["query": params, "variables": encodedInputs]
    }

    var unredactedParameterKeys: Set<String> {
        ["query"]
    }
}
