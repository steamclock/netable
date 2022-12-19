//
//  AuthNetworkService.swift
//  Example
//
//  Created by Amy Oulton on 2022-11-28.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Combine
import Foundation
import Netable

class AuthNetworkService {
    static var shared = AuthNetworkService()

    private let unauthNetable: Netable

    private var authNetable: Netable?
    var netable: Netable {
        authNetable ?? unauthNetable
    }

    var user: CurrentValueSubject<User?, Never>
    var authError: CurrentValueSubject<NetableError?, Never>
    var cancellables = [AnyCancellable]()

    init() {
        user = CurrentValueSubject<User?, Never>(nil)
        authError = CurrentValueSubject<NetableError?, Never>(nil)

        unauthNetable = Netable(
            baseURL: URL(string: "http://localhost:8080/")!)

        unauthNetable.requestFailurePublisher.sink { [weak self] error in
            if error.errorCode == 401 {
                self?.user.send(nil)
                self?.authError.send(error)
            }
        }.store(in: &cancellables)
    }

    func login(email: String, password: String) async throws {
        let login = try await netable.request(LoginRequest(parameters: LoginParameters(email: email, password: password)))

        authNetable = Netable(baseURL: URL(string: "http://localhost:8080/")!,
            config: Config(globalHeaders: ["Authentication" : "Bearer \(login.token)"]),
            logDestination: CustomLogDestination(),
            retryConfiguration: RetryConfiguration(errors: .all, count: 2, delay: 3.0),
            requestFailureDelegate: ErrorService.shared)
    }

    func getUser() {
        let (_, result) = netable.request(GetUserRequest(headers: ["Accept-Language": "en-US"]))
        result.sink { result in
            switch result {
            case .success(let user):
                self.user.send(user)
            case .failure(let error):
                print(error)
            }
        }.store(in: &cancellables)
    }

    func getPosts() async throws -> [Post] {
        try await netable.request(GetPostsRequest())
    }

    func createPost(title: String, content: String) {
        // this request is deliberately failing. Since there is a retry configuration set to the authNetable request, we are going to make use of `cancel()`
        // to cancel the task after sending it so it doesn't try again.

       let createRequest = Task {
            do {
               let result = try await netable.request(CreatePostRequest(parameters: CreatePostParameters(title: title, content: content)))
            } catch {
                print("Create request error: \(error)")
            }
        }

        // to see the retry configuration in action, comment out the below line and re-run the application. The request will not print the error
        // until the retry conditions have been met.
        createRequest.cancel()
    }

    func logout() {
        authNetable = nil
        self.user.send(nil)
    }
}
