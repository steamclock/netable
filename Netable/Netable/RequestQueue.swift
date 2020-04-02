//
//  RequestQueue.swift
//  Netable
//
//  Created by Brendan on 2020-04-01.
//  Copyright © 2020 Steamclock Software. All rights reserved.
//

import Foundation

open class RequestQueue {
    private var queue = [Result]()

    func enqueue(_ result: Result) {
        queue.append(result)
    }

    func next() -> Result? {
        return queue.first
    }

    func clearAll() {}
}
