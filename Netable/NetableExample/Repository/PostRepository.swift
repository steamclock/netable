//
//  PostRepository.swift
//  NetableExample
//
//  Created by Brendan on 2021-09-03.
//

import Combine
import Foundation
import Netable

class PostRepository {
    static var shared = PostRepository()

    /// If we aren't concerned with logging results from a particular instance, pass in the EmptyLogDestination as the logDestination
    private let netable = Netable(baseURL: URL(string: "http://localhost:8080/posts/")!)

    var posts: CurrentValueSubject<[Post], Never>
    var cancellables = [AnyCancellable]()

    private init() {
        posts = CurrentValueSubject<[Post], Never>([])
    }

    func checkVersion() {
        Task {
            do {
                try await netable.request(VersionCheckRequest())
                print("Version check successful!")
            } catch {
                if case NetableError.fallbackDecode = error {
                    print("Version check fallback successful!")
                    return
                }

                print("Version check failed. Better handle that.")
            }
        }
    }

    func getPosts() {
        Task { @MainActor in
            do {
                let posts = try await netable.request(GetPostsRequest())
                self.posts.send(posts)
            } catch {
                print(error)
            }
        }
    }

    func create(_ title: String, content: String, onComplete: @escaping () -> Void) {
        let params = CreatePostParams(title: title, content: content)

        netable.request(CreatePostRequest(parameters: params)) { result in
            onComplete()
        }
    }
}
