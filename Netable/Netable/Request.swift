//
//  Request.swift
//  Netable
//
//  Created by Brendan Lensink on 2018-10-18.
//  Copyright © 2020 Steamclock Software. All rights reserved.
//

import Foundation

/// The Request protocol defines the structure for any network requests run through Netable.
public protocol Request: Sendable {
    /// Parameters will be encoded and sent along with the request.
    associatedtype Parameters: Encodable, Sendable

    /// The raw data returned by the server from the request.
    associatedtype RawResource: Sendable

    /// An optional convenience type that allows for unwrapping of raw data to a predefined type.
    /// See `GetCatRequest` for a demonstration of this in action.
    associatedtype FinalResource: Sendable = RawResource

    /// An optional convenience type that Netable will try to use to decode your response if `RawResource` fails for any reason.
    /// See `FallbackDecoderViewController` for an example.
    associatedtype FallbackResource: Sendable = Sendable

    /// Allows for top-level arrays to be partially decoded if some elements fail to decode.
    var arrayDecodeStrategy: ArrayDecodeStrategy { get }

    /// Any headers that should be included with the request.
    /// Note that these will be set _after_ any global headers,
    /// and will thus take precedence if there's a duplicated key
    var headers: [String: String] { get }

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
    func decode(_ data: Data?, defaultDecodingStrategy: JSONDecoder.KeyDecodingStrategy) async throws -> RawResource

    /// Optional: The method to convert your RawResource returned by the server to FinalResource.
    func finalize(raw: RawResource) async throws -> FinalResource
}

public extension Request {
    var headers: [String: String] {
        [:]
    }

    var smartUnwrapKey: String {
        return ""
    }

    var unredactedParameterKeys: Set<String> {
        return Set<String>()
    }

    var arrayDecodeStrategy: ArrayDecodeStrategy {
        .standard
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

    /// Set the default key decoding strategy.
    var jsonKeyDecodingStrategy: JSONDecoder.KeyDecodingStrategy? {
        return nil
    }

    /// Set the default key encoding strategy.
    var jsonKeyEncodingStrategy: JSONEncoder.KeyEncodingStrategy? {
        return nil
    }
}

public extension Request where Parameters == Empty {
    /// Don't require filling in parameters for requests that don't send any.
    var parameters: Parameters {
        return Empty()
    }
}

public extension Request where FinalResource == RawResource {
    /// By default, `finalize` just returns the RawResource.
    func finalize(raw: RawResource) async throws -> FinalResource {
        return raw
    }
}

public extension Request where
    RawResource: Sequence,
    RawResource: Decodable,
    RawResource.Element: Decodable,
    RawResource.Element: Sendable
{
    func decode(_ data: Data?, defaultDecodingStrategy: JSONDecoder.KeyDecodingStrategy) async throws -> RawResource {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = jsonKeyDecodingStrategy ?? defaultDecodingStrategy

        guard let data = data else { throw NetableError.noData }

        do {
            guard arrayDecodeStrategy == .lossy else {
                return try decoder.decode(RawResource.self, from: data)
            }

            let decoded = try decoder.decode(LossyArray<RawResource.Element>.self, from: data)

            return decoded.elements as! Self.RawResource
        } catch {
            throw NetableError.decodingError(error, data)
        }
    }
}

public extension Request where RawResource: Decodable {
    func decode(_ data: Data?, defaultDecodingStrategy: JSONDecoder.KeyDecodingStrategy) async throws -> RawResource {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = jsonKeyDecodingStrategy ?? defaultDecodingStrategy

        do {
            if RawResource.self == Empty.self {
                return try decoder.decode(RawResource.self, from: Empty.data)
            } else if let data = data {
                return try decoder.decode(RawResource.self, from: data)
            }
        } catch {
            throw NetableError.decodingError(error, data)
        }

        throw NetableError.noData
    }
}

public extension Request where RawResource == Data {
    func decode(_ data: Data?, defaultDecodingStrategy: JSONDecoder.KeyDecodingStrategy) async throws -> RawResource {
        if let data = data {
            return data
        } else {
            throw NetableError.noData
        }
    }
}

extension CodingUserInfoKey {
    static let smartUnwrapKey = CodingUserInfoKey(rawValue: "smartUnwrapKey")!
}

public extension Request where
    RawResource == SmartUnwrap<FinalResource>,
    FinalResource: Sequence,
    FinalResource: Decodable,
    FinalResource.Element: Decodable,
    FinalResource.Element: Sendable
{
    func decode(_ data: Data?, defaultDecodingStrategy: JSONDecoder.KeyDecodingStrategy) async throws -> RawResource {
        guard let data = data else {
            throw NetableError.noData
        }

        do {
            let decoder = JSONDecoder()
            decoder.userInfo = [
                .smartUnwrapKey: smartUnwrapKey
            ]
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = jsonKeyDecodingStrategy ?? defaultDecodingStrategy


            guard arrayDecodeStrategy == .lossy else {
                return try decoder.decode(SmartUnwrap<FinalResource>.self, from: data)
            }

            let decodedType = try decoder.decode(SmartUnwrap<LossyArray<FinalResource.Element>>.self, from: data).decodedType
            guard let finalResource = decodedType.elements as? FinalResource,
                  let rawResource = SmartUnwrap(decodedType: finalResource) as? SmartUnwrap<FinalResource> else {
                throw NetableError.resourceExtractionError("Failed to smart unwrap lossy decodable type. This is an internal error.")
            }

            return rawResource
        } catch {
            throw NetableError.decodingError(error, data)
        }
    }
}



public extension Request where RawResource == SmartUnwrap<FinalResource> {
    func decode(_ data: Data?, defaultDecodingStrategy: JSONDecoder.KeyDecodingStrategy) async throws -> RawResource {
        guard let data = data else {
            throw NetableError.noData
        }

        do {
            let decoder = JSONDecoder()
            decoder.userInfo = [
                .smartUnwrapKey: smartUnwrapKey
            ]
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = jsonKeyDecodingStrategy ?? defaultDecodingStrategy

            let decodedResult = try decoder.decode(SmartUnwrap<FinalResource>.self, from: data)
            return decodedResult
        } catch {
            throw NetableError.decodingError(error, data)
        }
    }

    func finalize(raw: RawResource) async throws -> FinalResource {
        let unwrapped = raw as SmartUnwrap<FinalResource>
        return unwrapped.decodedType
    }
}

public extension Request where RawResource: Decodable, FallbackResource: Decodable {
    func decode(_ data: Data?, defaultDecodingStrategy: JSONDecoder.KeyDecodingStrategy) async throws -> RawResource {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = jsonKeyDecodingStrategy ?? defaultDecodingStrategy

        do {
            if RawResource.self == Empty.self {
                let raw = try decoder.decode(RawResource.self, from: Empty.data)
                return raw
            } else if let data = data {
                let raw = try decoder.decode(RawResource.self, from: data)
                return raw
            }
        } catch {
            if let data = data, let raw = try? decoder.decode(FallbackResource.self, from: data) {
                throw NetableError.fallbackDecode(raw)
            }

            let error = NetableError.decodingError(error, data)
            throw error
        }

        throw NetableError.noData
    }
}

public struct Empty: Codable, Sendable {
    public static let data = "{}".data(using: .utf8)!
}
