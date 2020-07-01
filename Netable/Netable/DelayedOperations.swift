//
//  DelayedOperations.swift
//  Netable
//
//  Created by Nigel Brooke on 2020-06-30.
//  Copyright © 2020 Steamclock Software. All rights reserved.
//

import Foundation

// Utility class for scheduling future operations that can easily be identified and cancelled later
// Used to hold in flight requests that are waiting for a retry.
internal class DelayedOperations {
    private var operations: [(timer: Timer, id: String)] = []

    func delay(_ delay: TimeInterval, withID id: String, doAction action: @escaping () -> Void) {
        self.operations.append((timer: Timer.scheduledTimer(withTimeInterval: delay, repeats: false, block: { timer in
            self.cancel(id)
            action()
        }), id: id))
    }

    @discardableResult
    func cancel(_ id: String) -> Bool {
        if let toCancel = operations.first(where: { $0.id == id }) {
            toCancel.timer.invalidate()
            operations.removeAll { $0.id == id }
            return true
        }
        return false
    }

    func cancelAll() {
        for operation in operations {
            operation.timer.invalidate()
        }

        operations.removeAll()
    }
}
