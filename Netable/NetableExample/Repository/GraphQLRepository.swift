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
    var errors: PassthroughSubject<Error, Never>

    private var cancellables = [AnyCancellable]()

    private init() {
        posts = CurrentValueSubject<[Post], Never>([])

        errors = PassthroughSubject<Error, Never>()
    }
    

    func getPosts() {
        let (_, results) = netable.request(GetAllPostsQuery())
            results.sink { result in
                switch result {
                case .success(let posts):
                    self.posts.send(posts)
                case .failure(let error):
                    print(error)
                }
            }.store(in: &cancellables)
    }

    func updatePost(id: String, title: String) {
        Task {
            do {
                let input = UpdatePostMutationInput(id: id, title: title)
                let post = try await netable.request(UpdatePostMutation(input: input))
            } catch {
                errors.send(error)
            }
        }
    }
}
