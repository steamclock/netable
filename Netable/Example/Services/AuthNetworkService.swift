//
//  AuthNetworkService.swift
//  Example
//
//  Created by Amy Oulton on 2022-11-28.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation
import Netable

class AuthNetworkService {
    static var shared = AuthNetworkService()

    private let unauthNetable: Netable

    private var authNetable: Netable?
    var netable: Netable {
        authNetable ?? unauthNetable
    }

    init() {
        unauthNetable = Netable(
            baseURL: URL(string: "http://localhost:8080/")!)
    }

    func login(email: String, password: String) async throws -> User? {
        let login = try await netable.request(LoginRequest(parameters: LoginParameters(email: email, password: password)))

        authNetable =  Netable(baseURL: URL(string: "http://localhost:8080/")!, config: Config(globalHeaders: ["Authentication" : "Bearer \(login.token)"]))

        return try await getUser()
    }

    func getUser() async throws -> User? {
        try await netable.request(UserRequest(headers: ["Accept-Language": "en-US"]))
    }

    func getPosts() async throws -> [Post] {
        try await netable.request(GetPostsRequest())
    }
}

