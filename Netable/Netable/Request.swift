//
//  Request.swift
//  Netable
//
//  Created by Brendan Lensink on 2018-10-18.
//  Copyright © 2018 steamclock. All rights reserved.
//

import Foundation

public protocol Request {
    associatedtype Parameters: Encodable
    associatedtype RawResource: Decodable
    associatedtype FinalResource: Any = RawResource
    var method: HTTPMethod { get }
    var path: String { get }
    var parameters: Parameters { get }

    func finalize(raw: RawResource) -> Result<FinalResource, NetableError>
}

extension Request where FinalResource == RawResource {
    public func finalize(raw: RawResource) -> Result<FinalResource, NetableError> {
        return .success(raw)
    }
}

public extension Request where Parameters == Empty {
    var parameters: Parameters {
        return Empty()
    }
}

public struct Empty: Codable {
    public static let data = "{}".data(using: .utf8)!
}
