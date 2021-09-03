//
//  LoginViewModel.swift
//  NetableExample
//
//  Created by Brendan on 2021-09-03.
//

import SwiftUI

class LoginViewModel: ObservableViewModel {

    @Published var user: User?

    @Published var email: String = ""
    @Published var password: String = ""
    @Published var submitEnabled = false

    override init() {
        super.init()

        UserRepository.shared.user.sink { user in
            self.user = user
        }.store(in: &cancellables)
    }

    func login() {
        UserRepository.shared.login(email: email, password: password)
    }
}
