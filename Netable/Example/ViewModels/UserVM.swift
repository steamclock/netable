//
//  UserVM.swift
//  Example
//
//  Created by Amy Oulton on 2022-12-01.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Combine
import Foundation

class UserVM: ObservableVM {
    @Published var user: User?

   override func bindViewModel() {
       super.bindViewModel()

        AuthNetworkService.shared.user
            .receive(on: RunLoop.main)
            .sink { [weak self] user in
                self?.user = user
            }.store(in: &cancellables)
    }

    func logout() {
        AuthNetworkService.shared.logout()
    }
}
