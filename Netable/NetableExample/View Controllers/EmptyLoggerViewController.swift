//
//  EmptyLoggerViewController.swift
//  NetableExample
//
//  Created by Brendan on 2020-03-20.
//  Copyright © 2020 Steamclock Software. All rights reserved.
//

import Netable
import UIKit

class EmptyLoggerViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!

    /// Create a Netable instance that won't record any logs
     private let netable = Netable(baseURL: URL(string: "https://api.thecatapi.com/v1/")!, logDestination: EmptyLogDestination())

     override func viewDidLoad() {
         super.viewDidLoad()
         // Do any additional setup after loading the view.

         netable.request(GetCatRequest()) { [weak self] result in
             guard let self = self else { return }

             switch result {
             case .success(let image):
                 self.imageView.image = image
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
