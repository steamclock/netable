//
//  ViewController.swift
//  SCNetworkAPI
//
//  Created by blensink192@gmail.com on 10/19/2018.
//  Copyright (c) 2018 blensink192@gmail.com. All rights reserved.
//

import SCNetworkAPI
import UIKit

struct CatImage: Decodable {
    let id: String
    let url: String
}

struct GetCat: Request {
    typealias Parameters = Empty
    typealias Returning = [CatImage]

    public var method: HTTPMethod { return .get }

    public var path: String {
        return "images/search?mime_type=jpg,png"
    }
}

class ViewController: UIViewController {
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
                debugPrint("Get cats request failed with error: \(error)")
            }
        }
    }
}

