//
//  DataManager.swift
//  Example
//
//  Created by Amy Oulton on 2023-01-20.
//  Copyright © 2023 Steamclock Software. All rights reserved.
//

import Foundation

class DataManager {
    static let shared = DataManager()

    var user: User?

    init(user: User? = nil) {
        self.user = user
    }

    func printData() {
        print("Data Manager User: ", user ?? "No User Found")
    }
}
