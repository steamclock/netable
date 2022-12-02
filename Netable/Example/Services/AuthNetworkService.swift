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
    var cancellables = [AnyCancellable]()
    
    init() {
        user = CurrentValueSubject<User?, Never>(nil)

        unauthNetable = Netable(
            baseURL: URL(string: "http://localhost:8080/")!)
    }

    func login(email: String, password: String) async throws {
        let login = try await netable.request(LoginRequest(parameters: LoginParameters(email: email, password: password)))

        authNetable = Netable(baseURL: URL(string: "http://localhost:8080/")!, config: Config(globalHeaders: ["Authentication" : "Bearer \(login.token)"]), logDestination: CustomLogDestination())
    }

    func getUser() async throws -> User? {
        let user = try await netable.request(UserRequest(headers: ["Accept-Language": "en-US"]))
        self.user.send(user)
        return user
    }

    func getPosts() async throws -> [Post] {
        try await netable.request(GetPostsRequest())
    }

    func logout() {
        authNetable = nil
        self.user.send(nil)
    }
}

