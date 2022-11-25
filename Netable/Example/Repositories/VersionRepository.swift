//
//  VersionRepository.swift
//  Example
//
//  Created by Amy Oulton on 2022-11-25.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation
import Netable

class VersionRepository {
    private let netable: Netable

    init() {
        netable = Netable(
            baseURL: URL(string: "http://localhost:8080/version")!)
    }

    func getVersion() async throws -> Version {
        try await netable.request(GetVersionRequest())
    }
}

