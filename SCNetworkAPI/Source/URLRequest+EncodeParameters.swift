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
            do {
                /*
                 While not ideal, the pattern of encode to json then decode to dictionary seems like the simplest way
                 to encode to dictionary until support is added to the Swift standard library. The goal here is to support passing params in as a variety of types, instead of just Dictionaries.
                 */
                let jsonEncodedParams = try JSONEncoder().encode(request.parameters)
                guard let url = url,
                        var components = URLComponents(url: url, resolvingAgainstBaseURL: true),
                        let params = try? JSONSerialization.jsonObject(with: jsonEncodedParams),
                        let paramsDict = params as? [String: Any] else {
                    throw NetworkAPIError.codingError("Encoding Error: Failed to unwrap url components")
                }

                if paramsDict.isEmpty {
                    return
                }

                // Make sure that our encoded dictionary doesn't contain any nested arrays or dicts
                for (_, value) in paramsDict where
                        (value as? [Any]) != nil ||
                        (value as? [AnyHashable: Any]) != nil {
                    throw NetworkAPIError.codingError("Encoding Error: Cannot encode nested dictionaries or arrays")
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
