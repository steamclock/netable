//
//  Version.swift
//  Example
//
//  Created by Amy Oulton on 2022-11-25.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation

struct SimpleVersion: Decodable {
    let buildNumber: String
}

struct Version: Decodable {
    let buildNumber: String
    let buildReleaseDate: Date
}
