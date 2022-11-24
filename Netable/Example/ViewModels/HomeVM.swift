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

    @Published var posts: [Post]?
    var cancellables: [AnyCancellable] = []


    func bindViewModel() {
        PostRepository.shared.posts
            .receive(on: RunLoop.main)
            .sink { posts in
                self.posts = posts
            }.store(in: &cancellables)

        Task { @MainActor in
            posts = try await PostRepository.shared.getPosts()
        }
    }


}
