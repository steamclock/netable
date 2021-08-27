//
//  SmartUnwrapViewController.swift
//  NetableExample
//
//  Created by Brendan on 2021-08-27.
//  Copyright © 2021 Steamclock Software. All rights reserved.
//

import Netable
import UIKit

class SmartUnwrapViewController: UIViewController {

    @IBOutlet private var catImageView: UIImageView!

    /// Create a Netable instance using the default log destination
    private let netable = Netable(baseURL: URL(string: "https://httpbin.org/")!)

    override func viewDidLoad() {
        super.viewDidLoad()

        let params = LoginParams(username: "username", password: "password", firstName: "Beep boop")
        netable.request(SmartUnwrapRequest(parameters: params)) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let image):
                print("success!")
            case .failure(let error):
                let alert = UIAlertController(
                    title: "Uh oh!",
                    message: "Get cat image failed with error: \(error)",
                    preferredStyle: .alert
                )

                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

