//
//  SampleDeleteViewController.swift
//  NetableExample
//
//  Created by Brendan on 2020-08-10.
//  Copyright © 2020 Steamclock Software. All rights reserved.
//

import Netable
import UIKit

class SampleDeleteViewController: UIViewController {
    @IBOutlet var label: UILabel!

    /// Create a Netable instance using the default log destination.
    private let netable = Netable(baseURL: URL(string: "https://httpbin.org/")!)

    override func viewDidLoad() {
        super.viewDidLoad()

        netable.request(DeleteRequest()) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success:
                self.label.text = "Deletion successful!"
            case .failure(let error):
                let alert = UIAlertController(
                    title: "Uh oh!",
                    message: "Delete failed with error: \(error)",
                    preferredStyle: .alert
                )

                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

