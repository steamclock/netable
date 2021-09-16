//
//  CreatePostRequest.swift
//  NetableExample
//
//  Created by Brendan on 2021-09-16.
//  Copyright © 2021 Steamclock Software. All rights reserved.
//

import Netable

struct CreatePostParams: Encodable {
    let title: String
    let content: String
}

struct CreatePostRequest: Request {
    typealias Parameters = CreatePostParams
    typealias RawResource = Empty

    var method = HTTPMethod.post

    var path = "create"

    var parameters: CreatePostParams
}
