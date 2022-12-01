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
    static var shared = SimpleNetworkService()

    private let netable: Netable

    init() {
        netable = Netable(
            baseURL: URL(string: "http://localhost:8080/")!)
    }

    func getVersion() async throws -> Version {
        try await netable.request(GetVersionRequest())
    }

}
