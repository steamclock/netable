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

    func bindViewModel() {
        Task { @MainActor in
            posts = try await AuthNetworkService.shared.getPosts()
        }
        getVersion()
    }

    func getVersion() {
        Task {
            let version = try await SimpleNetworkService.shared.getVersion()
            print(version.buildNumber)
        }
    }

    func login() {
        Task {
            try await AuthNetworkService.shared.login(email: username, password: password)
        }
    }

}
