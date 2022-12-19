//
//  GetPostsRequest.swift
//  Example
//
//  Created by Amy Oulton on 2022-11-23.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation
import Netable

struct GetPostsRequest: Request {
    typealias RawResource = SmartUnwrap<[Post]>
    typealias FinalResource = [Post]

    var method: HTTPMethod { return .get }

    var arrayDecodeStrategy: ArrayDecodeStrategy  { .lossy }

    var smartUnwrapKey = "posts"

    var path = "posts/all"

}
