//
//  GraphQLMutation.swift
//  Netable
//
//  Created by Brendan on 2022-09-12.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation

public protocol GraphQLMutation: GraphQLRequest {
    associatedtype Input: Encodable

    var input: Input { get }
}

public extension GraphQLMutation {
    var parameters: [String: String] {
        let params = "" // TODO getGraphQLQueryContents()

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
