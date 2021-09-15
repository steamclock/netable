//
//  VersionCheckRequest.swift
//  NetableExample
//
//  Created by Brendan on 2021-09-15.
//  Copyright © 2021 Steamclock Software. All rights reserved.
//

import Netable

struct VersionCheckRequest: Request {
    typealias Parameters = Empty
    typealias RawResource = Version
    typealias FallbackResource = SimpleVersion

    var method = HTTPMethod.get

    var path = "version"
}
