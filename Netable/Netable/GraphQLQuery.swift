//
//  GraphQLQuery.swift
//  Netable
//
//  Created by Brendan on 2022-09-12.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation

public protocol GraphQLQuery: GraphQLRequest {}

public extension GraphQLQuery {
    var parameters: [String: String] {
        let params = getGraphQLQueryContents()
        return ["query": params]
    }
}
