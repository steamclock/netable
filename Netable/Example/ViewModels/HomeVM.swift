//
//  HomeVM.swift
//  Example
//
//  Created by Amy Oulton on 2022-11-23.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Combine
import Foundation

class HomeVM: ObservableObject {

    @Published var username: String = ""
    @Published var password: String = ""
    @Published var title: String = ""
    @Published var content: String = ""

    @Published var posts: [Post]?
    @Published var user: User? 
    @Published var loginFailed = false

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
        
        getVersion()
    }

    func getVersion() {
        Task {
            let version = try await SimpleNetworkService.shared.getVersion()
            print(version.buildNumber)
        }
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
                loginFailed = true
            }
        }
    }

    func resetLoginSettings() {
        username = ""
        password = ""
        loginFailed = false
    }
}
