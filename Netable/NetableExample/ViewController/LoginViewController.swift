//
//  LoginViewController.swift
//  NetableExample
//
//  Created by Brendan on 2021-09-14.
//  Copyright © 2021 Steamclock Software. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet private var emailField: UITextField!
    @IBOutlet private var passwordField: UITextField!
    @IBOutlet private var submitButton: UIButton!

    private let viewModel = LoginViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction private func login(_ sender: Any) {
        guard let email = emailField.text, let password = passwordField.text else {
            // TODO: handle error
            return
        }

        viewModel.login(email: email, password: password)
    }
}
