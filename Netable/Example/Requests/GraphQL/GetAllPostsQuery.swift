//
//  GetAllPostsQuery.swift
//  Example
//
//  Created by Amy Oulton on 2022-12-08.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation
import Netable

struct GetAllPostsResponse: Decodable {
    let posts: [Post]
}

struct GetAllPostsQuery: GraphQLRequest {

    typealias Parameters = Empty
    typealias RawResource = GetAllPostsResponse
    typealias FinalResource = [Post]

    var source = GraphQLQuerySource.resource("GetAllPostsQuery")

    func finalize(raw: GetAllPostsResponse) async throws -> [Post] {
        raw.posts
    }
}
