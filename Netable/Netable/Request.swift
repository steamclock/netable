//
//  Request.swift
//  Netable
//
//  Created by Brendan Lensink on 2018-10-18.
//  Copyright © 2020 Steamclock Software. All rights reserved.
//

import Foundation

/// The Request protocol defines the structure for any network requests run through Netable.
public protocol Request {
    /// Parameters will be encoded and sent along with the request.
    associatedtype Parameters: Encodable

    /// The raw data returned by the server from the request.
    associatedtype RawResource: Any

    /// An optional convienience type that allows for unwrapping of raw data to a predefined type.
    /// See `GetCatRequest` for a demonstration of this in action.
    associatedtype FinalResource: Any = RawResource

    /// HTTP method the request will use. Currently GET, POST, PUT and PATCH are supported.
    var method: HTTPMethod { get }

    /// The path for this request, relative to the base URL defined when you created your Netable instance.
    var path: String { get }

    /// Parameters to be encoded and sent with the request.
    var parameters: Parameters { get }

    /// Optional: The key decoding strategy to be used when decoding return JSON.
    var jsonKeyDecodingStrategy: JSONDecoder.KeyDecodingStrategy { get }

    /// Optional: The method to decode Data into your RawResource
    func decode(_ data: Data?) -> Result<RawResource, NetableError>

    /// Optional: The method to convert your RawResource returned by the server to FinalResource.
    func finalize(raw: RawResource) -> Result<FinalResource, NetableError>
}

public extension Request where Parameters == Empty {
    /// Don't require filling in parameters for requests that don't send any.
    var parameters: Parameters {
        return Empty()
    }
}

public extension Request {
    /// Set the default key decoding strategy.
    var jsonKeyDecodingStrategy: JSONDecoder.KeyDecodingStrategy {
        return .useDefaultKeys
    }
}

public extension Request where FinalResource == RawResource {
    /// By default, `finalize` just returns the RawResource.
    func finalize(raw: RawResource) -> Result<FinalResource, NetableError> {
        return .success(raw)
    }
}

public extension Request where RawResource: Decodable {
    func decode(_ data: Data?) -> Result<RawResource, NetableError> {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = jsonKeyDecodingStrategy

            if RawResource.self == Empty.self {
                let raw = try decoder.decode(RawResource.self, from: Empty.data)
                return .success(raw)
            } else if let data = data {
                let raw = try decoder.decode(RawResource.self, from: data)
                return .success(raw)
            } else {
                return .failure(.noData)
            }
        } catch {
            let error = NetableError.decodingError(error, data)
            return .failure(error)
        }
    }
}

public extension Request where RawResource == Data {
    func decode(_ data : Data?) -> Result<RawResource, NetableError> {
        if let data = data {
            return .success(data)
        } else {
            return .failure(.noData)
        }
    }
}

public struct Empty: Codable {
    public static let data = "{}".data(using: .utf8)!
}
