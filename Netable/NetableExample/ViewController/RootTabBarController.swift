//
//  RootTabBarController.swift
//  NetableExample
//
//  Created by Brendan on 2021-09-15.
//  Copyright © 2021 Steamclock Software. All rights reserved.
//

import Netable
import UIKit

class RootTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        PostRepository.shared.checkVersion()
    }
}

extension RootTabBarController: RequestFailureDelegate {
    func requestDidFail<T>(_ request: T, error: NetableError) where T : Request {
        // Ignore 401 unauthorized errors, we'll handle those in the UserRepository
        if case let NetableError.httpError(statusCode, _) = error, statusCode == 401 {
            return
        }

        let alert = UIAlertController(title: "Error", message: error.errorDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true, completion: nil)
    }
}
