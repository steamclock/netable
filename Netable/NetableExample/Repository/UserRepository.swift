//
//  UserRepository.swift
//  NetableExample
//
//  Created by Brendan on 2021-09-03.
//

import Combine
import Foundation
import Netable

class UserRepository {
    static var shared = UserRepository()

    private let netable = Netable(baseURL: URL(string: "http://localhost:8080/user/")!)

    var user: CurrentValueSubject<User?, Never>
    var cancellables = [AnyCancellable]()

    private init() {
        user = CurrentValueSubject<User?, Never>(nil)
    }

    public func login(email: String, password: String) {
        let params = LoginParams(email: email, password: password)

        netable.request(LoginRequest(parameters: params)) { [weak self] result in
            guard let self = self else { return }

            if case .success(let user) = result {
                self.user.send(user)
            }
        }
    }

    public func getUserDetails() {
        let params = UserDetailsParams(email: "", token: "")

        netable.request(GetUserDetailsRequest(parameters: params)) { [weak self] result in
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
