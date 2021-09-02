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

    /// If using SmartUnwrap, you need to specify the key that your object is stored in.
    var smartUnwrapKey: String { get }

    /// Parameter keys whose values will be printed in full to logs.
    /// By default, all parameters will be printed as `<REDACTED>` to logs.
    var unredactedParameterKeys: Set<String> { get }

    /// Optional: The key decoding strategy to be used when decoding return JSON. Default is `.useDefaultKeys`.
    var jsonKeyDecodingStrategy: JSONDecoder.KeyDecodingStrategy? { get }

    /// Optional: The key encoding strategy to be used when encoding JSON parameters. Default is `.useDefaultKeys`.
    var jsonKeyEncodingStrategy: JSONEncoder.KeyEncodingStrategy? { get }

    /// Optional: The method to decode Data into your RawResource
    func decode(_ data: Data?, defaultDecodingStrategy: JSONDecoder.KeyDecodingStrategy) -> Result<RawResource, NetableError>

    /// Optional: The method to convert your RawResource returned by the server to FinalResource.
    func finalize(raw: RawResource) -> Result<FinalResource, NetableError>
}

public extension Request {
    var smartUnwrapKey: String {
        return ""
    }

    var unredactedParameterKeys: Set<String> {
        return Set<String>()
    }

    func unredactedParameters(defaultEncodingStrategy: JSONEncoder.KeyEncodingStrategy) -> [String: String] {
        var output = [String: String]()

        guard let paramsDict = try? parameters.toParameterDictionary(encodingStrategy: self.jsonKeyEncodingStrategy ?? defaultEncodingStrategy) else {
            return output
        }
        
        for (key, value) in paramsDict {
            if unredactedParameterKeys.contains(key) {
                output[key] = value
            } else {
                output[key] = "<REDACTED>"
            }
        }

        return output
    }
}

public extension Request where Parameters == Empty {
    /// Don't require filling in parameters for requests that don't send any.
    var parameters: Parameters {
        return Empty()
    }
}

public extension Request {
    /// Set the default key decoding strategy.
    var jsonKeyDecodingStrategy: JSONDecoder.KeyDecodingStrategy? {
        return nil
    }

    /// Set the default key encoding strategy.
    var jsonKeyEncodingStrategy: JSONEncoder.KeyEncodingStrategy? {
        return nil
    }
}

public extension Request where FinalResource == RawResource {
    /// By default, `finalize` just returns the RawResource.
    func finalize(raw: RawResource) -> Result<FinalResource, NetableError> {
        return .success(raw)
    }
}

public extension Request where RawResource: Decodable {
    func decode(_ data: Data?, defaultDecodingStrategy: JSONDecoder.KeyDecodingStrategy) -> Result<RawResource, NetableError> {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = jsonKeyDecodingStrategy ?? defaultDecodingStrategy

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
    func decode(_ data : Data?, defaultDecodingStrategy: JSONDecoder.KeyDecodingStrategy) -> Result<RawResource, NetableError> {
        if let data = data {
            return .success(data)
        } else {
            return .failure(.noData)
        }
    }
}

extension CodingUserInfoKey {
    static let smartUnwrapKey = CodingUserInfoKey(rawValue: "smartUnwrapKey")!
}


public extension Request where RawResource == SmartUnwrap<FinalResource> {
    func decode(_ data: Data?, defaultDecodingStrategy: JSONDecoder.KeyDecodingStrategy) -> Result<SmartUnwrap<FinalResource>, NetableError> {

        guard let data = data else {
            return .failure(.noData)
        }

        do {
            let decoder = JSONDecoder()
            decoder.userInfo = [
                .smartUnwrapKey: smartUnwrapKey
            ]
            let decodedResult = try decoder.decode(SmartUnwrap<FinalResource>.self, from: data)
            return .success(decodedResult)
        } catch {
            let error = NetableError.decodingError(error, data)
            return .failure(error)
        }
    }

    func finalize(raw: RawResource) -> Result<FinalResource, NetableError> {
        let unwrapped = raw as SmartUnwrap<FinalResource>
        return .success(unwrapped.decodedType)
    }
}

public struct Empty: Codable {
    public static let data = "{}".data(using: .utf8)!
}


