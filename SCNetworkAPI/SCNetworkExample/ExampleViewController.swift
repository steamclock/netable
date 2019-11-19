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
    typealias RawResource = [CatImage]
    typealias FinalResource = URL

    public var method: HTTPMethod { return .get }

    public var path: String {
        return "images/search"
    }

    public var parameters: [String: String] {
        return ["mime_type": "jpg,png"]
    }

    func finalize(raw: RawResource) -> Result<FinalResource, NetworkAPIError> {
        guard let catImage = raw.first else {
            return .failure(NetworkAPIError.resourceExtractionError("The CatImage array is empty"))
        }

        guard let url = URL(string: catImage.url) else {
            return .failure(NetworkAPIError.resourceExtractionError("Could not build URL from CatImage url string"))
        }

        return .success(url)
    }
}

struct GetCatImages: Request {
    typealias Parameters = [String: String]
    typealias RawResource = [CatImage]

    public var method: HTTPMethod { return .get }

    public var path: String {
        return "images/search"
    }

    public var parameters: [String: String] {
        return ["mime_type": "jpg,png", "limit": "2"]
    }
}

class ExampleViewController: UIViewController {
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var catsImageView1: UIImageView!
    @IBOutlet private var catsImageView2: UIImageView!

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
                let alert = UIAlertController(
                    title: "Uh oh!",
                    message: "Get cat url request failed with error: \(error)",
                    preferredStyle: .alert
                )

                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(alert, animated: true, completion: nil)
            }
        }

        api.request(GetCatImages()) { result in
            switch result {
            case .success(let catImages):
                if let firstCat = catImages.first,
                   let url = URL(string: firstCat.url),
                   let imageData = try? Data(contentsOf: url) {
                    self.catsImageView1.image = UIImage(data: imageData)
                }

                if let lastCat = catImages.last,
                   let url = URL(string: lastCat.url),
                   let imageData = try? Data(contentsOf: url) {
                    self.catsImageView2.image = UIImage(data: imageData)
                }
            case .failure(let error):
                let alert = UIAlertController(
                    title: "Uh oh!",
                    message: "Get cats request failed with error: \(error)",
                    preferredStyle: .alert
                )

                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
