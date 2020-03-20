//
//  CatImage.swift
//  NetableExample
//
//  Created by Jeremy Chiang on 2020-02-10.
//  Copyright © 2020 Steamclock Software. All rights reserved.
//

import Netable
import UIKit

struct CatImage: Decodable {
    let id: String
    let url: String
}

struct GetCatImage: Request {    
    typealias Parameters = [String: String]
    typealias RawResource = [CatImage]
    typealias FinalResource = UIImage

    public var method: HTTPMethod { return .get }

    public var path: String {
        return "images/search"
    }

    public var parameters: [String: String] {
        return ["mime_type": "jpg,png"]
    }

    func finalize(raw: RawResource) -> Result<FinalResource, NetableError> {
        guard let catImage = raw.first else {
            return .failure(NetableError.resourceExtractionError("The expected cat image array is empty"))
        }

        guard let url = URL(string: catImage.url) else {
            return .failure(NetableError.resourceExtractionError("The expected cat image url is invalid"))
        }

        do {
            let data = try Data(contentsOf: url)

            if let image = UIImage(data: data) {
                return .success(image)
            } else {
                return .failure(NetableError.resourceExtractionError("Could not create image from the cat image data"))
            }
        } catch {
            return .failure(NetableError.resourceExtractionError("Could not load contents of the cat image url"))
        }
    }
}
