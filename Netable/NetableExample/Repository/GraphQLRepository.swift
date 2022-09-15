//
//  GraphQLRepository.swift
//  NetableExample
//
//  Created by Brendan on 2022-09-12.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Combine
import Foundation
import Netable

class GraphQLRepository {
    static var shared = GraphQLRepository()
    private let netable = Netable(baseURL: URL(string: "http://localhost:8080/graphql/")!)

    var posts: CurrentValueSubject<[Post], Never>

    private init() {
        posts = CurrentValueSubject<[Post], Never>([])
    }

    func getPosts() {
        netable.request(GetAllPostsQuery()) { result in
            switch result {
            case .success(let posts):
                self.posts.send(posts)
            case .failure(let error):
                print("failure: \(error.localizedDescription)")
            }
        }
    }
}
