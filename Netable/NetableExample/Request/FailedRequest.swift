//
//  FailedRequest.swift
//  NetableExample
//
//  Created by Brendan on 2021-09-15.
//  Copyright © 2021 Steamclock Software. All rights reserved.
//

import Netable

struct FailedRequest: Request {
    typealias Parameters = Empty
    typealias RawResource = Empty

    var method = HTTPMethod.get

    var path = "failed"
}
