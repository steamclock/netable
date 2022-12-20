//
//  GetVersionRequest.swift
//  Example
//
//  Created by Amy Oulton on 2022-11-28.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation
import Netable

struct GetVersionRequest: Request {
    typealias Parameters = Empty
    typealias RawResource = Version
    typealias FallbackResource = SimpleVersion

    var method: HTTPMethod { .get }
    var path = "version"
}
