//
//  Error404ViewController.swift
//  NetableExample
//
//  Created by Brendan on 2020-03-23.
//  Copyright © 2020 Steamclock Software. All rights reserved.
//

import Netable
import UIKit

class Error404ViewController: UIViewController {
    @IBOutlet weak var errorLabel: UILabel!

    // Create a Netable instance that won't record logs to anywhere
    private let netable = Netable(baseURL: URL(string: "https://api.thecatapi.com/1a2a3a/")!, logDestination: EmptyLogDestination())

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        let errorRequest = Error404Request(expectedErrorResponses: [
            ExpectedErrorResponse(code: 404) { [weak self] data in
                if let data = data,
                        let dataString = String(data: data, encoding: .utf8) {
                    self?.errorLabel.text = dataString
                }
            }
        ])

        netable.request(errorRequest) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success:
                break
            case .failure(let error):
                let alert = UIAlertController(
                    title: "Uh oh!",
                    message: "Request failed with error: \(error)",
                    preferredStyle: .alert
                )

                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
