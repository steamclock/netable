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

    let netable: Netable

    var user: CurrentValueSubject<User?, Never>

    var cancellables = [AnyCancellable]()

    private init() {
        user = CurrentValueSubject<User?, Never>(nil)

        netable = Netable(baseURL: URL(string: "http://localhost:8080/user/")!, requestFailureDelegate: ErrorService.shared)

        // Listen for 401 errors and if we get one, clear the current user
        netable.requestFailurePublisher.sink { [weak self] error in
            guard case let NetableError.httpError(statusCode, _) = error, statusCode == 401 else {
                return
            }

            self?.user.send(nil)
        }.store(in: &cancellables)
    }

    func login(email: String, password: String) throws {
        let params = LoginParams(email: email, password: password)

        Task {
            let user = try await netable.request(LoginRequest(parameters: params))

            await MainActor.run {
                self.user.send(user)
            }
        }
    }

    func getUserDetails() throws {
        let params = UserDetailsParams(email: "", token: "")

        Task {
            let userDetails = try await netable.request(GetUserDetailsRequest(parameters: params))

            await MainActor.run {
                self.user.send(userDetails)
            }
        }
    }

    public func unauthorizedRequest() {
        Task {
            netable.request(UnauthorizedRequest())
        }
    }

    public func failedRequest() {
        Task {
            netable.request(FailedRequest())
        }
    }

    public func logout() {
        self.user.send(nil)
    }
}

