//
//  Request+AsyncAwait.swift
//  Netable
//
//  Created by Brendan on 2022-09-27.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation

extension Netable {
    /*
     * Convenience function that allows Netable to work with Swift's async/await
     *
     * Note that is can be potentially not thread safe, as the `decode` and `finalize` functions run on a background
     * thread, but have no safeguards to make sure they do not touch any global or static variables.
     */
    @discardableResult public func request<T: Request>(_ request: T) async throws -> T.FinalResource {
        try await withCheckedThrowingContinuation { continuation in
            self.request(request) { response in
                switch response {
                case .success(let result):
                    continuation.resume(returning: result)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
