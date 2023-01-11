//
//  GraphQLNetworkService.swift
//  Example
//
//  Created by Amy Oulton on 2022-12-07.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation
import Netable

class GraphQLNetworkService {
    static var shared = GraphQLNetworkService()

    private let netable = Netable(baseURL: URL(string: "http://localhost:8080/graphql")!)

    func getPosts() async throws -> [Post] {
        try await netable.request(GetAllPostsQuery())
    }

    func updatePost(title: String, content: String) async throws {
        let input = UpdatePostMutationInput(title: title, content: content)
        try await netable.request(UpdatePostsMutation(input: input))
    }
}
