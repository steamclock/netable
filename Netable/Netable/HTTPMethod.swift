//
//  HTTPMethod.swift
//  Netable
//
//  Created by Jeremy Chiang on 2020-02-04.
//  Copyright © 2020 Steamclock Software. All rights reserved.
//

import Foundation

/// Type representing all supported HTTP methods.
public enum HTTPMethod: String {
    case delete = "DELETE"
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
}
