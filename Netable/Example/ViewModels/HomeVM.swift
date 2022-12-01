//
//  HomeVM.swift
//  Example
//
//  Created by Amy Oulton on 2022-11-23.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation

class HomeVM: ObservableObject {

    @Published var username: String = ""
    @Published var password: String = ""
    @Published var posts: [Post]?
    @Published var user: User? 
    @Published var loginFailed = false

    func bindViewModel() {
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

    func login() {
        Task { @MainActor in
            do {
                user = try await AuthNetworkService.shared.login(email: username, password: password)
                getPosts()
            } catch {
                loginFailed = true
            }
        }
    }
}
