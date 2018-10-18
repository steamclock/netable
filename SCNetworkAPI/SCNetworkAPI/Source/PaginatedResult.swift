//
//  PaginatedResult.swift
//  SCNetworkAPI
//
//  Created by Brendan Lensink on 2018-10-18.
//  Copyright © 2018 steamclock. All rights reserved.
//

import Foundation

public struct PaginatedResults<T: Decodable>: Decodable {
    public let count: Int
    public let next: String?
    public let previous: String?
    public let results: [T]

    // MARK: Computed
    public var hasMore: Bool {
        return next != nil
    }
}
