//
//  UserRepository.swift
//  NetableExample
//
//  Created by Brendan on 2021-09-02.
//  Copyright © 2021 Steamclock Software. All rights reserved.
//

import Combine
import Foundation
import Netable

class UserRepository {
    static var shared = UserRepository()

    private let netable = Netable(baseURL: URL(string: "http://localhost:8080/user/")!)

    var user: CurrentValueSubject<User?, Never>

    private init() {
        user = CurrentValueSubject<User?, Never>(nil)
    }

    public func login(username: String, password: String) {
        let params = LoginParams(username: username, password: password)

        netable.request(LoginRequest(parameters: params)) { [weak self] result in
            guard let self = self else { return }

            if case .success(let user) = result {
                self.user.send(user)
            }
        }
    }

    public func logout() {
        self.user.send(nil)
    }
}
