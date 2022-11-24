//
//  PostRepository.swift
//  Example
//
//  Created by Amy Oulton on 2022-11-23.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Combine
import Foundation
import Netable

class PostRepository {
    static var shared = PostRepository()

    private let netable: Netable

    var posts: CurrentValueSubject<[Post], Never>


    init() {
        posts = CurrentValueSubject<[Post], Never>([])

        netable = Netable(
            baseURL: URL(string: "http://localhost:8080/posts/")!)
    }

    func getPosts() async throws -> [Post] {
            let posts = try await netable.request(GetPostsRequest())
            self.posts.send(posts)
            return posts
    }

}
