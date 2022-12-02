//
//  GetPostsRequest.swift
//  NetableExample
//
//  Created by Brendan on 2021-09-15.
//  Copyright © 2021 Steamclock Software. All rights reserved.
//

import Netable

struct GetPostsRequest: Request {
    typealias Parameters = Empty
    typealias RawResource = Result
    typealias FinalResource = [Post]

    struct Result: Decodable {
        let posts: LossyArray<Post>
    }

    var method = HTTPMethod.get

    var path = "all"

    var unredactedParameterKeys: Set<String> {
        ["title", "content"]
    }

    func finalize(raw: Result) async throws -> [Post] {
        raw.posts.elements
    }
}
