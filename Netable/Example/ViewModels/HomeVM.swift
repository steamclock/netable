//
//  HomeVM.swift
//  Example
//
//  Created by Amy Oulton on 2022-11-23.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation

class HomeVM: ObservableObject {

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

            let login = try await AuthNetworkService.shared.login(email: "sirmeows@netable.com", password: "ififitsisits")
        }
    }

}
