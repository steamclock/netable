//
//  ProfileViewController.swift
//  NetableExample
//
//  Created by Brendan on 2021-09-14.
//  Copyright © 2021 Steamclock Software. All rights reserved.
//

import Combine
import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet private var firstNameLabel: UILabel!
    @IBOutlet private var lastNameLabel: UILabel!
    @IBOutlet private var emailLabel: UILabel!
    @IBOutlet private var locationLabel: UILabel!

    private var cancellables = [AnyCancellable]()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true

        bindUserRepository()
    }

    @IBAction private func logout(_ sender: Any) {
        UserRepository.shared.logout()
    }

    @IBAction private func trigger401Error(_ sender: Any) {
        UserRepository.shared.unauthorizedRequest()
    }

    @IBAction func triggerOtherError(_ sender: Any) {
        UserRepository.shared.failedRequest()
    }

    private func bindUserRepository() {
        UserRepository.shared.getUserDetails()
        UserRepository.shared.user.sink { user in
            self.emailLabel.text = user?.email
            self.firstNameLabel.text = user?.firstName
            self.lastNameLabel.text = user?.lastName
            self.locationLabel.text = user?.location
        }.store(in: &cancellables)
    }
}
