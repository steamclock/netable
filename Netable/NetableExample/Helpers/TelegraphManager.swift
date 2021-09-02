//
//  SwifterManager.swift
//  NetableExample
//
//  Created by Brendan on 2021-09-01.
//  Copyright © 2021 Steamclock Software. All rights reserved.
//

import Swifter

class SwifterManager {
    static let shared = SwifterManager()

    private let server: HttpServer

    private init() {
        server = HttpServer()

        server["/login"] = { _ in
            .ok(.json(["url": "alice@example.com"]))
        }

        try! server.start()

    }
}
