//
//  GraphQLVM.swift
//  Example
//
//  Created by Amy Oulton on 2022-12-07.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation

@MainActor
class GraphQLVM: ObservableObject {
    @Published var posts: [Post]?
    @Published var title: String = ""
    @Published var content: String = ""

    func getPosts() {
        Task { @MainActor in
            posts = try await GraphQLNetworkService.shared.getPosts()
        }
    }

    func updatePosts() {
        Task { @MainActor in
            try await GraphQLNetworkService.shared.updatePost(title: title, content: content)
        }
    }
}
