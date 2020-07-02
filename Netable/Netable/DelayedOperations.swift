//
//  DelayedOperations.swift
//  Netable
//
//  Created by Nigel Brooke on 2020-06-30.
//  Copyright © 2020 Steamclock Software. All rights reserved.
//

import Foundation

// Utility class for scheduling future operations that can easily be identified and cancelled later
// Used to hold in-flight requests that are waiting for a retry.
internal class DelayedOperations {
    private var localQueue = DispatchQueue(label: "Netable DelayedOperations")
    private var actionQueue: DispatchQueue
    private var operations: [(timer: DispatchSourceTimer, id: String)] = []

    init(dispatchOn: DispatchQueue = DispatchQueue.main) {
        actionQueue = dispatchOn
    }

    func delay(_ delay: TimeInterval, withID id: String, doAction action: @escaping () -> Void) {
        let timer = DispatchSource.makeTimerSource(queue: actionQueue)
        timer.schedule(deadline: .now() + delay)
        timer.setEventHandler {
            self.cancel(id)
            action()
        }

        localQueue.sync {
            operations.append((timer: timer, id: id))
        }

        timer.resume()
    }

    @discardableResult
    func cancel(_ id: String) -> Bool {
        self.localQueue.sync {
            let origCount = operations.count
            operations.removeAll { $0.id == id }
            return operations.count != origCount
        }
    }

    func cancelAll() {
        self.localQueue.sync {
            operations.removeAll()
        }
    }
}
