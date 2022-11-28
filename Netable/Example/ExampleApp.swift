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
        MockNetworkService.shared
    }

    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: HomeVM())
        }
    }
}
