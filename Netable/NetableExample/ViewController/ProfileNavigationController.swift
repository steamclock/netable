//
//  ProfileNavigationController.swift
//  NetableExample
//
//  Created by Brendan on 2021-09-14.
//  Copyright © 2021 Steamclock Software. All rights reserved.
//

import Combine
import UIKit

enum ProfileSegue: String {
    case toProfile
}

class ProfileNavigationController: UINavigationController {
    private var cancellables = [AnyCancellable]()

    private var previousUser: User?

    override func viewDidLoad() {
        super.viewDidLoad()

        UserRepository.shared.user.sink { user in
            guard user != nil else {
                self.previousUser = nil
                self.popToRootViewController(animated: true)
                return
            }

            if self.previousUser == nil {
                self.performSegue(withIdentifier: ProfileSegue.toProfile.rawValue, sender: self)
            }
            self.previousUser = user
        }.store(in: &cancellables)
    }
}
