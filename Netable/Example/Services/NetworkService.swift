//
//  SimpleNetworkService.swift
//  Example
//
//  Created by Amy Oulton on 2022-11-28.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Combine
import Foundation
import Netable

class SimpleNetworkService {
    static let shared = SimpleNetworkService()

    private let netable = Netable(baseURL: URL(string: "http://localhost:8080/")!)

    func getVersion() {
        Task {
            do {
                let version = try await netable.request(GetVersionRequest())
            } catch {
                print(error)
            }
        }
    }
}
