//
//  GraphQLVM.swift
//  Example
//
//  Created by Amy Oulton on 2022-12-07.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation

class GraphQLVM: ObservableObject {
    @Published var posts: [Post]?

    func getPosts() {
        Task { @MainActor in
            posts = try await GraphQLNetworkService.shared.getPosts()
        }
    }
}
