//
//  ExpectedErrorResponse.swift
//  Netable
//
//  Created by Brendan on 2020-03-23.
//  Copyright © 2020 Steamclock Software. All rights reserved.
//

import Foundation

public struct ExpectedErrorResponse {
    var code: Int
    var handler: (Data?) -> Void

    public init(code: Int, handler: @escaping ((Data?) -> Void)) {
        self.code = code
        self.handler = handler
    }
}
