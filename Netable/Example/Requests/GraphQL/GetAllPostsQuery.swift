//
//  GetAllPostsQuery.swift
//  Example
//
//  Created by Amy Oulton on 2022-12-08.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation
import Netable

struct GetAllPostsQuery: GraphQLRequest {
    typealias Parameters = Empty
    typealias RawResource = SmartUnwrap<[Post]>
    typealias FinalResource = [Post]

    var source = GraphQLQuerySource.resource("GetAllPostsQuery")
}
