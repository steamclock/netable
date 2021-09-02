//
//  AppDelegate.swift
//  NetableExample
//
//  Created by Jeremy Chiang on 2020-02-10.
//  Copyright © 2020 Steamclock Software. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Poke our local web server to get it started.
        _ = SwifterManager.shared
        return true
    }
}

