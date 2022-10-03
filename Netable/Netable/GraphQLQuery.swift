//
//  GraphQLQuery.swift
//  Netable
//
//  Created by Brendan on 2022-09-12.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation

/// This protocol extends the default `Request` protocol, adding support for making GraphQL query requests.
public protocol GraphQLQuery: GraphQLRequest {}

public extension GraphQLQuery {
    /// Fetches and encodes the query for this request.
    var parameters: [String: String] {
        let params = getGraphQLQueryContents()
        return ["query": params]
    }
}
