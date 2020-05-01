//
//  Notification.swift
//  Netable
//
//  Created by Brendan Lensink on 2018-10-18.
//  Copyright © 2018 Steamclock Software. All rights reserved.
//

import Foundation

extension Notification.Name {
    public static let NetableRequestDidComplete = Notification.Name(rawValue: "com.steamclock.netable.notification.name.requestDidComplete")
}

extension Notification {
    public struct Netable {
        public static let request = "com.steamclock.netable.key.request"
        public static let response = "com.steamclock.netable.key.response"
        public static let responseData = "com.steamclock.netable.key.responseData"
        public static let responseError = "com.steamclock.netable.key.responseError"
        public static let duration = "com.steamclock.netable.key.duration"
    }
}

class NetableNotification {
    /**
     * Encode user info from a successful network request to send through `NotificationCenter`
     *
     * - parameter request: The request that triggered this response
     * - parameter data: Any data supplied by the request response
     * - parameter response: The request response
     * - parameter error: The request error if applicable
     *
     * - returns: The user info encoded as a `Dictionary<String, Any>`
     */
    static func userInfo(forRequest request: URLRequest?, data: Data?, response: URLResponse?, duration: CFTimeInterval?, error: Swift.Error?) -> [String: Any] {
        var userInfo: [String: Any] = [:]

        if let request = request {
            userInfo[Notification.Netable.request] = request
        }

        if let data = data {
            userInfo[Notification.Netable.responseData] = data
        }

        if let response = response {
            userInfo[Notification.Netable.response] = response
        }

        if let duration = duration {
            userInfo[Notification.Netable.duration] = duration
        }

        if let error = error {
            userInfo[Notification.Netable.responseError] = error
        }

        return userInfo
    }
}
