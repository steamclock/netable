//
//  CombineViewController.swift
//  NetableExample
//
//  Created by Brendan on 2021-08-30.
//  Copyright © 2021 Steamclock Software. All rights reserved.
//

import Combine
import Netable
import UIKit

class CombineViewController: UIViewController {
    @IBOutlet var label: UILabel!

    /// Create a Netable instance using the default log destination.
    private let netable = Netable(baseURL: URL(string: "https://api.thecatapi.com/v1/")!)
    private var cancellables = [AnyCancellable]()

    override func viewDidLoad() {
        super.viewDidLoad()

        netable.request(GetCatRequest()).sink(
            receiveCompletion: { error in
                let alert = UIAlertController(
                    title: "Uh oh!",
                    message: "GET failed with error: \(error)",
                    preferredStyle: .alert
                )

                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(alert, animated: true, completion: nil)
            }, receiveValue: { finalResource in
                self.label.text = "\(finalResource)"
            }).store(in: &cancellables)
    }
}
