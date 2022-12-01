//
//  UserVM.swift
//  Example
//
//  Created by Amy Oulton on 2022-12-01.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation

class UserVM: ObservableObject {
    @Published var user: User?


    func bindViewModel() {
        Task { @MainActor in
          user = try await AuthNetworkService.shared.getUser()
        }
    }
}
