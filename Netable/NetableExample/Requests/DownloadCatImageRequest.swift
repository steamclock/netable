//
//  DownloadCatImageRequest.swift
//  NetableExample
//
//  Created by Jake Miner on 2020-04-01.
//  Copyright © 2020 Steamclock Software. All rights reserved.
//

import Netable
import UIKit

struct DownloadCatImageRequest: DownloadRequest {
    typealias Parameters = Empty
    typealias FinalResource = UIImage

    let imageUrl: String

    public var method: HTTPMethod { return .get }

    var enforceBaseURL: Bool { return false }

    public var path: String {
        return imageUrl
    }

    func finalize(data: Data) -> Result<FinalResource, NetableError> {
        if let image = UIImage(data: data) {
            return .success(image)
        } else {
            return .failure(NetableError.resourceExtractionError("Could not create image from the cat image data"))
        }
    }
}
