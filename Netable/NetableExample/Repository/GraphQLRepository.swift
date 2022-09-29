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
        Task {
            do {
                let posts = try await netable.request(GetAllPostsQuery())
                self.posts.send(posts)
            } catch {
                errors.send(error)
            }
        }
    }

    func updatePost(id: String, title: String) {
        Task {
            do {
                let input = UpdatePostMutationInput(id: id, title: title)
                let post = try await netable.request(UpdatePostMutation(input: input))
                print("Updated \(post)")
            } catch {
                errors.send(error)
            }
        }
    }
}
