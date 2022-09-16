//
//  UpdatePostMutation.swift
//  NetableExample
//
//  Created by Brendan on 2022-09-12.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation
import Netable

struct UpdatePostMutationInput: Codable {
    let id: String
    let title: String
}

struct UpdatePostMutation: GraphQLMutation {
    typealias Input = UpdatePostMutationInput

    typealias RawResource = Bool

    var input: UpdatePostMutationInput

    var source = GraphQLQuerySource.autoResource
}
