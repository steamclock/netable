//
//  CancelRequestViewController.swift
//  NetableExample
//
//  Created by Brendan on 2020-04-02.
//  Copyright © 2020 Steamclock Software. All rights reserved.
//

import Netable
import UIKit

class CancelRequestViewController: UIViewController {

    /// Create a Netable instance using the default log destination.
    private let netable = Netable(baseURL: URL(string: "https://api.thecatapi.com/v1/")!)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Make your request as you normally would, but store the `RequestIdentifier` provided by `Request` to refer to later.
        let taskId = netable.request(GetCatRequest()) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success:
                print("Request success!")
            case .failure:
                // Handle the cancelled request here
                let alert = UIAlertController(
                    title: "Uh oh!",
                    message: "Request cancelled.",
                    preferredStyle: .alert
                )

                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(alert, animated: true, completion: nil)
            }
        }

        // Use that `RequestIdentifier` to cancel your request
        netable.cancel(byId: taskId)

        // Or cancel using the `RequestIdentifier`, if you don't want to store a reference to your `Netable` object.
        // taskId.cancel()
    }
}
