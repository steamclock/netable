//
//  FallbackDecoderViewController.swift
//  NetableExample
//
//  Created by Brendan on 2021-08-31.
//  Copyright © 2021 Steamclock Software. All rights reserved.
//

import Netable
import UIKit

class FallbackDecoderViewController: UIViewController {
    @IBOutlet private var label: UILabel!

    private let netable = Netable(baseURL: URL(string: "https://httpbin.org/")!)

    override func viewDidLoad() {
        // Bundle your login params up to pass into your request.
        let params = SimpleVersion(id: "1.2.3")

        // Call `request()`, passing in your parameters.
        netable.request(FallbackDecoderRequest(parameters: params)) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let response):
                self.label.text = "\(response)"
            case .failure(let error):
                switch error {
                case .fallbackDecode(let fallbackResponse):
                    self.label.text = "\(fallbackResponse)"
                default:
                    let alert = UIAlertController(
                        title: "Uh oh!",
                        message: "Fetch failed with error: \(error)",
                        preferredStyle: .alert
                    )

                    alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
