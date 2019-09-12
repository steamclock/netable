//
//  Notification.swift
//  SCNetworkAPI
//
//  Created by Brendan Lensink on 2018-10-18.
//  Copyright © 2018 steamclock. All rights reserved.
//

import Foundation

extension Notification.Name {
    public static let NetworkAPIRequestDidComplete = Notification.Name(rawValue: "com.steamclock.scNetworkAPI.notification.name.requestDidComplete")
}

extension Notification {
    public struct NetworkAPI {
        public static let request = "com.steamclock.scNetworkAPI.key.request"
        public static let response = "com.steamclock.scNetworkAPI.key.response"
        public static let responseData = "com.steamclock.scNetworkAPI.key.responseData"
        public static let responseError = "com.steamclock.scNetworkAPI.key.responseError"
        public static let duration = "com.steamclock.scNetworkAPI.key.duration"
    }
}
