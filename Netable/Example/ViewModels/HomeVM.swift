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
    var postRepo = PostRepository()
    var versionRepo = VersionRepository()

    @Published var posts: [Post]?
    var cancellables: [AnyCancellable] = []


    func bindViewModel() {
        postRepo.posts
            .receive(on: RunLoop.main)
            .sink { posts in
                self.posts = posts
            }.store(in: &cancellables)

        Task { @MainActor in
            posts = try await postRepo.getPosts()
        }
        getVersion()
    }

    func getVersion() {
        Task {
            let version = try await versionRepo.getVersion()
            print(version.buildNumber)
        }
    }

}
