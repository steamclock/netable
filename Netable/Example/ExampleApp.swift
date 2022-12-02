//
//  ExampleApp.swift
//  Example
//
//  Created by Amy Oulton on 2022-11-23.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import SwiftUI

@main
struct ExampleApp: App {
    init() {
        // We have to initalize this here for the server to start, or else the first request will fail.
        MockNetworkService.shared
    }

    var body: some Scene {
        WindowGroup {
            RootView(viewModel: HomeVM())
        }
    }
}
