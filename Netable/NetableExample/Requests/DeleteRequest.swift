//
//  DeleteRequest.swift
//  NetableExample
//
//  Created by Brendan on 2020-08-10.
//  Copyright © 2020 Steamclock Software. All rights reserved.
//

import Netable

struct DeleteRequest: Request {
    typealias Parameters = Empty
    typealias RawResource = Empty

    public var method: HTTPMethod { return .delete }

    public var path: String {
        return "/delete"
    }
}
