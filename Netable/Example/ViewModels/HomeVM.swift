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
    @Published var title: String = ""
    @Published var content: String = ""
    @Published var posts: [Post]?

    private var cancellables = [AnyCancellable]()

    func unbindViewModel() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }

    func bindViewModel() {
        unbindViewModel()
        getPosts()
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
}
