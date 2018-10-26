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
            guard let url = url,
                    var components = URLComponents(url: url, resolvingAgainstBaseURL: true),
                    let paramsDict = request.parameters as? [String: Codable] else {
                throw NetworkAPI.Error.codingError("Encoding error: Failed to create url parameters dictionary")
            }

            guard !paramsDict.isEmpty else {
                throw NetworkAPI.Error.codingError("Parameters is empty")
            }

            components.queryItems = paramsDict.map {
                URLQueryItem(name: $0, value: "\($1)")
            }

            self.url = components.url
        default:
            setValue("application/json", forHTTPHeaderField: "Content-Type")

            do {
                httpBody = try JSONEncoder().encode(request.parameters)
            } catch {
                throw NetworkAPI.Error.codingError("Request JSON encoding failed, probably due to an invalid value")
            }
        }
    }
}
