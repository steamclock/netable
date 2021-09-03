//
//  GetPostsRequest.swift
//  NetableExample
//
//  Created by Brendan on 2021-09-03.
//

import Netable

struct GetPostsRequest: Request {
    typealias Parameters = Empty
    typealias RawResourse = SmartUnwrap<[Post]>
    typealias FinalizedResource = [Post]

    var method = HTTPMethod.get

    var path = "all"

    var parameters: Empty
}
