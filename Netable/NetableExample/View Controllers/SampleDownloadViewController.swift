//
//  ViewController.swift
//  NetableExample
//
//  Created by Jeremy Chiang on 2020-02-10.
//  Copyright © 2020 Steamclock Software. All rights reserved.
//

import Netable
import UIKit

class SampleDownloadViewController: UIViewController {

    @IBOutlet private var catImageView: UIImageView!

    /// Create a Netable instance using the default log destination
    private let netable = Netable(baseURL: URL(string: "https://api.thecatapi.com/v1/")!)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        netable.request(DownloadCatImageRequest(imageUrl: "https://cdn2.thecatapi.com/images/se.jpg")) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let image):
                self.catImageView.image = image
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

