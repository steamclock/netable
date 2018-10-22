//
//  ExampleViewController.swift
//  SCNetworkExample
//
//  Created by Brendan Lensink on 2018-10-19.
//

import SCNetworkAPI
import UIKit

struct CatImage: Decodable {
    let id: String
    let url: String
}

struct GetCat: Request {
    typealias Parameters = [String: String]
    typealias Returning = [CatImage]

    public var method: HTTPMethod { return .get }

    public var path: String {
        return "images/search"
    }

    public var parameters: [String: String] {
        return ["mime_type": "jpg,png"]
    }
}

class ExampleViewController: UIViewController {
    @IBOutlet private var imageView: UIImageView!

    private let api = NetworkAPI(baseURL: URL(string: "https://api.thecatapi.com/v1/")!)

    override func viewDidLoad() {
        super.viewDidLoad()

        api.request(GetCat()) { result in
            switch result {
            case .success(let cats):
                guard let cat = cats.first,
                    let url = URL(string: cat.url),
                    let data = try? Data(contentsOf: url) else {
                        return
                }

                self.imageView.image = UIImage(data: data)
            case .failure(let error):
                let alert = UIAlertController(title: "Uh oh!", message: "Get cats request failed with error: \(error)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
