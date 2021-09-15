//
//  ProfileViewController.swift
//  NetableExample
//
//  Created by Brendan on 2021-09-14.
//  Copyright © 2021 Steamclock Software. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet private var firstNameLabel: UILabel!
    @IBOutlet private var lastNameLabel: UILabel!
    @IBOutlet private var emailLabel: UILabel!
    @IBOutlet private var locationLabel: UILabel!

    private let viewModel = ProfileViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true

        viewModel.bindViewModel()

        UserRepository.shared.user.sink { user in
            self.emailLabel.text = user?.email
            self.firstNameLabel.text = user?.firstName
            self.lastNameLabel.text = user?.lastName
            self.locationLabel.text = user?.location
        }.store(in: &viewModel.cancellables)
    }

    @IBAction func logout(_ sender: Any) {
        viewModel.logout()
    }
}
