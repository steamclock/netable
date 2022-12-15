//
//  RootVM.swift
//  Example
//
//  Created by Amy Oulton on 2022-12-15.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Combine
import Foundation
import Netable

class RootVM: ObservableObject {

    let homeVM = HomeVM()
    let userVM = UserVM()
    let graphQLVM = GraphQLVM()

    @Published var username: String = ""
    @Published var password: String = ""
    @Published var user: User?
    @Published var error: String?

    private var cancellables = [AnyCancellable]()

    func unbindViewModel() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }

    func bindViewModel() {
        unbindViewModel()

        AuthNetworkService.shared.user
            .receive(on: RunLoop.main)
            .sink { user in
                self.user = user
            }.store(in: &cancellables)

        AuthNetworkService.shared.authError
            .receive(on: RunLoop.main)
            .sink { error in
                self.error = error?.errorDescription
            }.store(in: &cancellables)
        
        ErrorService.shared.errors
            .receive(on: RunLoop.main)
            .sink { error in
                self.error = error?.errorDescription
            }.store(in: &cancellables)

        getVersion()
    }

    func getVersion() {
          SimpleNetworkService.shared.getVersion()
    }

    func getUser() {
        Task { @MainActor in
            try await AuthNetworkService.shared.getUser()
        }
    }

    func login() {
        Task { @MainActor in
            do {
                try await AuthNetworkService.shared.login(email: username, password: password)
                resetLoginSettings()
                getUser()
            } catch {
                print(error)
            }
        }
    }

    func fillForm() {
        username = "cat@netable.com"
        password = "meows"
    }

    func resetLoginSettings() {
        username = ""
        password = ""
    }

    func clearError() {
        error = nil
    }
}
