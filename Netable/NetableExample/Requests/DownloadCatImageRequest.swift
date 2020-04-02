//
//  DownloadCatImageRequest.swift
//  NetableExample
//
//  Created by Jake Miner on 2020-04-01.
//  Copyright © 2020 Steamclock Software. All rights reserved.
//

import Netable
import UIKit

struct DownloadCatImageRequest: Request {
    typealias Parameters = Empty
    typealias FinalResource = UIImage
    typealias RawResource = Data

    let imageUrl: String

    public var method: HTTPMethod { return .get }

    var enforceBaseURL: Bool { return false }

    public var path: String {
        return imageUrl
    }

    func decode(_ data: Data?) -> Result<Data, NetableError> {
        if let data = data {
            return .success(data)
        } else {
            return .failure(.noData)
        }
    }

    func finalize(raw: Data) -> Result<UIImage, NetableError> {
        if let image = UIImage(data: raw) {
            return .success(image)
        } else {
            return .failure(NetableError.resourceExtractionError("Could not create image from the cat image data"))
        }
    }
}
