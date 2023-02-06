//
//  LoginVM.swift
//  Example
//
//  Created by Amy Oulton on 2022-12-19.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Combine
import Foundation

@MainActor
class LoginVM: ObservableVM {
    @Published var user: User?
    @Published var username: String = ""
    @Published var password: String = ""

   override func bindViewModel() {
       super.bindViewModel()

        AuthNetworkService.shared.user
            .receive(on: RunLoop.main)
            .sink { [weak self] user in
                self?.user = user
            }.store(in: &cancellables)
    }

    func login() {
        Task { @MainActor in
            do {
                try await AuthNetworkService.shared.login(email: username, password: password)
                AuthNetworkService.shared.getUser()
                resetLoginSettings()
            } catch {
                print(error)
            }
        }
    }

    func fillForm() {
        username = "cat@example.com"
        password = "meows"
    }

    func resetLoginSettings() {
        username = ""
        password = ""
    }
}
