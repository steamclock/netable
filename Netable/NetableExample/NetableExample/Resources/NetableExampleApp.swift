//
//  NetableExampleApp.swift
//  NetableExample
//
//  Created by Brendan on 2021-09-03.
//

import SwiftUI

@main
struct NetableExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Poke our local web server to get it started
                    _ = SwifterManager.shared
                }
        }
    }
}
