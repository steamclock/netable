//
//  ProfileViewModel.swift
//  NetableExample
//
//  Created by Brendan on 2021-09-14.
//  Copyright © 2021 Steamclock Software. All rights reserved.
//

import Combine
import Foundation

class ProfileViewModel {
    var cancellables = [AnyCancellable]()

    let user: CurrentValueSubject<User?, Never>

    init() {
        user = UserRepository.shared.user
    }

    func bindViewModel() {
        UserRepository.shared.getUserDetails()
    }

    func logout() {
        UserRepository.shared.logout()
    }
}
