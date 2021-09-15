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

     let netable = Netable(baseURL: URL(string: "http://localhost:8080/user/")!)

    var user: CurrentValueSubject<User?, Never>
    var cancellables = [AnyCancellable]()

    private init() {
        user = CurrentValueSubject<User?, Never>(nil)

        // Listen for 401 errors and if we get one, clear the current user
        netable.requestFailurePublisher.sink { [weak self] error in
            guard case let NetableError.httpError(statusCode, _) = error, statusCode == 401 else {
                return
            }

            self?.user.send(nil)
        }.store(in: &cancellables)
    }

    func login(email: String, password: String) {
        let params = LoginParams(email: email, password: password)

        netable.request(LoginRequest(parameters: params)) { [weak self] result in
            guard let self = self else { return }

            if case .success(let user) = result {
                self.user.send(user)
            }
        }
    }

    func getUserDetails() {
        let params = UserDetailsParams(email: "", token: "")

        netable.request(GetUserDetailsRequest(parameters: params)) { [weak self] result in
            guard let self = self else { return }

            if case .success(let user) = result {
                self.user.send(user)
            }
        }
    }

    public func unauthorizedRequest() {
        netable.request(UnauthorizedRequest()) { _ in
            // Since we know this request is going to fail, do nothing.
            return
        }
    }

    public func failedRequest() {
        netable.request(FailedRequest()) { _ in
            // Since we know this request is going to fail, do nothing.
            return
        }
    }

    public func logout() {
        self.user.send(nil)
    }
}
