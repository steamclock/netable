//
//  GlobalRequestFailureDelegateExample.swift
//  NetableExample
//
//  Created by Brendan on 2021-08-24.
//  Copyright © 2021 Steamclock Software. All rights reserved.
//

import Netable
import SwiftUI

class GlobalRequestFailureDelegateExample: UIViewController {

    @IBOutlet private var catImageView: UIImageView!

    /// Create a Netable instance using the default log destination
    /// Note we're intentionally using an endpoint here we know will return a 404 to test error handling
    private let netable = Netable(baseURL: URL(string: "https://api.thecatapi.com/404")!)

    override func viewDidLoad() {
        super.viewDidLoad()

        netable.requestFailureDelegate = self

        netable.request(GetCatRequest()) { [weak self] result in
            guard let self = self else { return }

            // Since we don't care about the failure case, we can swap our usual switch statement out for an `if case`!
            if case .success(let image) = result {
                self.catImageView.image = image
            }
        }
    }
}

extension GlobalRequestFailureDelegateExample: RequestFailureDelegate {
    func requestDidFail<T>(_ request: T, error: NetableError) where T : Request {
        let alert = UIAlertController(title: "Uh oh!", message: error.errorDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}


