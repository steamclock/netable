//
//  Version.swift
//  NetableExample
//
//  Created by Brendan on 2021-09-15.
//  Copyright © 2021 Steamclock Software. All rights reserved.
//

import Foundation

struct SimpleVersion: Decodable {
    let buildNumber: String
}

struct Version: Decodable {
    let buildNumber: String
    let deprecatedBuilds: [String]
}
