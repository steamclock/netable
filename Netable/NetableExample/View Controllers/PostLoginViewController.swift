//
//  PostLoginViewController.swift
//  NetableExample
//
//  Created by Brendan on 2020-03-16.
//  Copyright © 2020 Steamclock Software. All rights reserved.
//

import Netable
import UIKit

class PostLoginViewController: UIViewController {
    @IBOutlet private var usernameField: UITextField!
    @IBOutlet private var passwordField: UITextField!
    @IBOutlet private var submitButton: UIButton!
    @IBOutlet private var resultLabel: UILabel!

    private let netable = Netable(baseURL: URL(string: "https://httpbin.org/")!)

    override func viewDidLoad() {
        super.viewDidLoad()

        usernameField.delegate = self
        passwordField.delegate = self
    }

    @IBAction func submitPressed(_ sender: Any) {
        guard let username = usernameField.text,
                let password = passwordField.text else {
            fatalError("Managed to pres submit without a username or password, something's gone wrong.")
        }

        let params = LoginParams(username: username, password: password)
        netable.request(LoginRequest(parameters: params)) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(_):
                self.resultLabel.text = "Success!"
            case .failure(let error):
                let alert = UIAlertController(
                    title: "Uh oh!",
                    message: "Login failed with error: \(error)",
                    preferredStyle: .alert
                )

                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

extension PostLoginViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        submitButton.isEnabled = usernameField.text?.isEmpty == false && usernameField.text?.isEmpty == false
        return true
    }
}
