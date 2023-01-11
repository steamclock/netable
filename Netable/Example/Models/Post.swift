//
//  Post.swift
//  Example
//
//  Created by Amy Oulton on 2022-11-23.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation

struct Post: Codable, Hashable {
    let title: String
    let content: String
}
