//
//  CreatePostRequest.swift
//  Example
//
//  Created by Amy Oulton on 2022-12-02.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation
import Netable

struct CreatePostParameters: Encodable {
    let title: String
    let content: String
}

struct CreatePostRequest: Request {
    typealias Parameters = CreatePostParameters
    typealias RawResource = Empty

    var method: HTTPMethod { .post }
    var parameters: CreatePostParameters
    var path = "posts/new"
}
