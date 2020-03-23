//
//  Error404Request.swift
//  NetableExample
//
//  Created by Brendan on 2020-03-23.
//  Copyright © 2020 Steamclock Software. All rights reserved.
//

import Netable

struct Error404Request: Request {
    typealias Parameters = Empty
    typealias RawResource = Empty

    public var method: HTTPMethod { return .get }

    public var path: String {
        return "/1a2a3a"
    }

    public var expectedErrorResponses: [ExpectedErrorResponse]
}
