//
//  UserNetworkService.swift
//  Example
//
//  Created by Amy Oulton on 2022-11-28.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation
import Netable

class UserNetworkService {
    static var shared = UserNetworkService()

    private let unauthNetable: Netable

    private var authNetable: Netable?
    var netable: Netable {
        authNetable ?? unauthNetable
    }

    init() {
        unauthNetable = Netable(
            baseURL: URL(string: "http://localhost:8080/user/")!)
    }

    func login(email: String, password: String) async throws {
        let login = try await netable.request(LoginRequest(parameters: LoginParameters(email: "sirmeows@netable.com", password: "ififitsisits")))

        authNetable =  Netable(baseURL: URL(string: "http://localhost:8080/user/")!, config: Config(globalHeaders: ["Authentication" : "Bearer \(login.token)"]))

        try await getUser()
    }

    func getUser() async throws -> User? {
        try await netable.request(UserRequest(headers: ["Accept-Language": "en-US"]))
    }

}

