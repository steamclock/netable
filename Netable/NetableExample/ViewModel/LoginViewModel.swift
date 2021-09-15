//
//  LoginViewModel.swift
//  NetableExample
//
//  Created by Brendan on 2021-09-14.
//  Copyright © 2021 Steamclock Software. All rights reserved.
//

import Foundation

class LoginViewModel {
    
    func login(email: String, password: String) {
        UserRepository.shared.login(email: email, password: password)
    }
}
