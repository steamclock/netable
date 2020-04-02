//
//  Request.swift
//  Netable
//
//  Created by Brendan Lensink on 2018-10-18.
//  Copyright © 2018 steamclock. All rights reserved.
//

import Foundation

/// Adds a deprecated Request for compatability with older clients
@available(*, deprecated, message: "Please use JSONRequest instead of Request")
public typealias Request = JSONRequest

/// The base BaseRequest protocol defines the structure for any network requests run through Netable.
public protocol BaseRequest {
    /// Parameters will be encoded and sent along with the request.
    associatedtype Parameters: Encodable

    /// The raw data returned by the server from the request.
    associatedtype RawResource: Decodable

    /// An optional convienience type that allows for unwrapping of raw data to a predefined type.
    /// See `GetCatRequest` for a demonstration of this in action.
    associatedtype FinalResource: Any = RawResource

    /// HTTP method the request will use. Currently GET, POST, PUT and PATCH are supported.
    var method: HTTPMethod { get }

    /// The path for this request, relative to the base URL defined when you created your Netable instance.
    var path: String { get }

    /// Parameters to be encoded and sent with the request.
    var parameters: Parameters { get }
}

public extension BaseRequest where Parameters == Empty {
    /// Don't require filling in parameters for requests that don't send any.
    var parameters: Parameters {
        return Empty()
    }
}

public struct Empty: Codable {
    public static let data = "{}".data(using: .utf8)!
}

// The JSONRequest protocol defines additional structure on top of BaseRequest for use with JSON data
public protocol JSONRequest: BaseRequest {
    /// Optional: The key decoding strategy to be used when decoding return JSON.
    var jsonKeyDecodingStrategy: JSONDecoder.KeyDecodingStrategy { get }

    /// Optional: The method to convert your RawResource returned by the server to FinalResource.
    func finalize(raw: RawResource) -> Result<FinalResource, NetableError>
}

public extension JSONRequest {
    /// Set the default key decoding strategy.
    var jsonKeyDecodingStrategy: JSONDecoder.KeyDecodingStrategy {
        return .useDefaultKeys
    }
}

public extension JSONRequest where FinalResource == RawResource {
    /// By default, `finalize` just returns the RawResource.
    func finalize(raw: RawResource) -> Result<FinalResource, NetableError> {
        return .success(raw)
    }
}

// The DownloadRequest protocol defines additional structure on top of BaseRequest for use with raw Data
public protocol DownloadRequest: BaseRequest where RawResource == Data {
    /// Optional: The method to convert Data returned by the server to FinalResource.
    func finalize(data: Data) -> Result<FinalResource, NetableError>

    /// Optional: Allow downloading from outside of the BaseUrl
    var enforceBaseURL: Bool { get }
}

public extension DownloadRequest {
    var enforceBaseURL: Bool {
        return true
    }
}

public extension DownloadRequest where FinalResource == Data {
    func finalize(data: Data) -> Result<FinalResource, NetableError> {
        return .success(data)
    }
}
