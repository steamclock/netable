//
//  Request.swift
//  SCNetworkAPI
//
//  Created by Brendan Lensink on 2018-10-18.
//  Copyright © 2018 steamclock. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
}

public enum Result<Value> {
    case success(Value)
    case failure(NetworkAPIError)
}

public protocol Request {
    associatedtype Parameters: Encodable
    associatedtype Returning: Decodable

    var method: HTTPMethod { get }
    var path: String { get }
    var parameters: Parameters { get }
}

public extension Request where Parameters == Empty {
    var parameters: Parameters {
        return Empty()
    }
}

public struct Empty: Codable {
    public static let data = "{}".data(using: .utf8)!
}
