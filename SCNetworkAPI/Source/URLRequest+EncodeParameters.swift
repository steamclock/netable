//
//  URLRequest+EncodeParameters.swift
//  SCNetworkAPIMobile
//
//  Created by Brendan Lensink on 2018-10-26.
//

import Foundation

extension URLRequest {
    mutating func encodeParameters<T: Request>(for request: T) throws {
        switch request.method {
        case .get:
            // Check to make sure parameters aren't any of the disallowed types: Array, nested Dictionaries or SingleValueEncodingContainer
            // TODO: These currently don't work. Array<String> != Array<Codable>
            if T.Parameters.self == SingleValueEncodingContainer.self ||
                T.Parameters.self == [Codable].self ||
                T.Parameters.self == [String: [Codable]].self {
                throw NetworkAPIError.codingError("Encoding Error: Can't encode parameters of type \(T.Parameters.self)")
            }

            do {
                let jsonEncodedParams = try JSONEncoder().encode(request.parameters)
                guard let url = url,
                        var components = URLComponents(url: url, resolvingAgainstBaseURL: true),
                        let paramsDict = try JSONDecoder().decode(AnyDecodable.self, from: jsonEncodedParams).value as? [String: Any] else {
                    throw NetworkAPIError.codingError("Encoding Error: Failed to unwrap url components")
                }

                if paramsDict.isEmpty {
                    return
                }

                components.queryItems = paramsDict.map {
                    URLQueryItem(name: $0, value: "\($1)")
                }

                self.url = components.url
            } catch {
                throw NetworkAPIError.codingError("Encoding error: Failed to create url parameters: \(error)")
            }
        default:
            setValue("application/json", forHTTPHeaderField: "Content-Type")

            do {
                httpBody = try JSONEncoder().encode(request.parameters)
            } catch {
                throw NetworkAPIError.codingError("Request JSON encoding failed, probably due to an invalid value")
            }
        }
    }
}
