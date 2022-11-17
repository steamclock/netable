//
//  GetAllPostsQuery.swift
//  NetableExample
//
//  Created by Brendan on 2022-09-12.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation
import Netable

struct GetAllPostsResponse: Decodable {
    let posts: [Post]
}

struct GetAllPostsQuery: GraphQLRequest {
    typealias RawResource = GetAllPostsResponse
    typealias FinalResource = [Post]

    var source = GraphQLQuerySource.resource("GetAllPostsQuery")

    func finalize(raw: GetAllPostsResponse) async throws -> [Post] {
        raw.posts
    }
}
