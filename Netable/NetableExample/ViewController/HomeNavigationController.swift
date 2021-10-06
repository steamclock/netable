//
//  HomeNavigationController.swift
//  NetableExample
//
//  Created by Brendan on 2021-09-14.
//  Copyright © 2021 Steamclock Software. All rights reserved.
//

import Combine
import Netable
import UIKit

class HomeNavigationController: UINavigationController {
    private var cancellables = [AnyCancellable]()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("--- vdl")
        UserRepository.shared.netable.requestFailureDelegate = self
    }
}

extension HomeNavigationController: RequestFailureDelegate {
    func requestDidFail<T>(_ request: T, error: NetableError) where T : Request {
        print("==== request did fail")
        // Ignore 401 unauthorized errors, we'll handle those in the UserRepository
        if case let NetableError.httpError(statusCode, _) = error, statusCode == 401 {
            return
        }

        let alert = UIAlertController(title: "Error", message: error.errorDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true, completion: nil)
    }
}
