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
    private let netable: Netable

    var posts: CurrentValueSubject<[Post], Never>
    var cancellables = [AnyCancellable]()

    private init() {
        posts = CurrentValueSubject<[Post], Never>([])

        netable = Netable(
            baseURL: URL(string: "http://localhost:8080/posts/")!,
            retryConfiguration: RetryConfiguration(errors: .all, count: 2)
        )
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
                let posts = try await self.netable.request(GetPostsRequest())
                print(posts)
                self.posts.send(posts)
            } catch {
                print(error)
            }
        }
    }

    func create(_ title: String, content: String, onComplete: @escaping () -> Void) {
        let params = CreatePostParams(title: title, content: content)

        // This request is set to return an error, and will retry due to the netable configuration set above
        // we keep a reference to the task so we can manually cancel the request
        let task = netable.request(CreatePostRequest(parameters: params)) { result in
            onComplete()
        }

        task.cancel()

        // We can achieve the same thing with async/await by creating a new task and saving a reference to it, then calling `cancel` on that task.
        let createTask = Task {
            do {
                let result = try await netable.request(CreatePostRequest(parameters: params))
                print("Post created! \(result)")
            } catch {
                print(error)
            }
        }
        createTask.cancel()
    }
}
