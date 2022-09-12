//
//  UpdateFilmMutation.swift
//  NetableExample
//
//  Created by Brendan on 2022-09-12.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation
import Netable

struct UpdateFilmMutationInput: Codable {
    let id: String
    let title: String
}

struct UpdateFilmMutation: GraphQLMutation {
    typealias Input = UpdateFilmMutationInput

    typealias RawResource = Bool

    var input: UpdateFilmMutationInput

    var unredactedParameterKeys: Set<String> {
        ["input", "query"]
    }
}
