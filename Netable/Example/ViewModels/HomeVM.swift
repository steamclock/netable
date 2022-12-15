//
//  HomeVM.swift
//  Example
//
//  Created by Amy Oulton on 2022-11-23.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Combine
import Foundation
import Netable

class HomeVM: ObservableObject {

    @Published var username: String = ""
    @Published var password: String = ""
    @Published var title: String = ""
    @Published var content: String = ""

    @Published var posts: [Post]?
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

    func getPosts() {
        Task { @MainActor in
            posts = try await AuthNetworkService.shared.getPosts()
        }
    }

    func createPost() {
        Task { @MainActor in
            try await AuthNetworkService.shared.createPost(title: title, content: content)
        }
    }

    func getUser() {
        Task { @MainActor in
            try await AuthNetworkService.shared.getUser()
            getPosts()
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
