//
//  DecodeCustomLoggingViewController.swift
//  NetableExample
//
//  Created by Brendan on 2020-03-20.
//  Copyright © 2020 Steamclock Software. All rights reserved.
//

import Netable
import UIKit

class DecodeSnakeCaseViewController: UIViewController {
    @IBOutlet private var paramsLabel: UILabel!
    @IBOutlet private var resultLabel: UILabel!

    private let client = Netable(baseURL: URL(string: "https://reqres.in/")!)

    override func viewDidLoad() {
        super.viewDidLoad()

        let sampleGet = SampleGetJSON(parameters: ["sample_param": "1a2a3a4a"])
        paramsLabel.text = "Sending params \(sampleGet.parameters)"

        client.request(sampleGet) { result in
            switch result {
            case .success(_):
                self.resultLabel.text = "Result: \(result)"
            case .failure(let error):
                let alert = UIAlertController(
                    title: "Uh oh!",
                    message: "Get failed with error: \(error)",
                    preferredStyle: .alert
                )

                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(alert, animated: true, completion: nil)
            }

        }
    }

}
