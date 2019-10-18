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

struct GetCatImageURL: Request {
    typealias Parameters = [String: String]
    typealias Returning = [CatImage]
    typealias FinalResource = URL

    public var method: HTTPMethod { return .get }

    public var path: String {
        return "images/search"
    }

    public var parameters: [String: String] {
        return ["mime_type": "jpg,png"]
    }

    func finalize(raw: [CatImage]) -> Result<URL, NetworkAPIError> {
        guard let catImage = raw.first else {
            return .failure(NetworkAPIError.resourceExtractionError("The CatImage array is empty"))
        }

        guard let url = URL(string: catImage.url) else {
            return .failure(NetworkAPIError.resourceExtractionError("Could not build URL from CatImage url string"))
        }

        return .success(url)
    }
}

class ExampleViewController: UIViewController {
    @IBOutlet private var imageView: UIImageView!

    private let api = NetworkAPI(baseURL: URL(string: "https://api.thecatapi.com/v1/")!)

    override func viewDidLoad() {
        super.viewDidLoad()

        api.request(GetCatImageURL()) { result in
            switch result {
            case .success(let catUrl):
                guard let imageData = try? Data(contentsOf: catUrl) else {
                    return
                }

                self.imageView.image = UIImage(data: imageData)
            case .failure(let error):
                let alert = UIAlertController(title: "Uh oh!", message: "Get cats request failed with error: \(error)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
