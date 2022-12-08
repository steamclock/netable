//
//  UpdatePostsMutation.swift
//  Example
//
//  Created by Amy Oulton on 2022-12-08.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation
import Netable

struct UpdatePostMutationInput: Codable {
    let title: String
    let content: String
}

struct UpdatePostsMutation: GraphQLRequest {
    typealias Input = UpdatePostMutationInput
    typealias RawResource = GetAllPostsResponse
    typealias FinalResource = [Post]

    var input: UpdatePostMutationInput

    var source = GraphQLQuerySource.resource("UpdatePostsMutation")

    func finalize(raw: GetAllPostsResponse) async throws -> [Post] {
        raw.posts
    }
}
