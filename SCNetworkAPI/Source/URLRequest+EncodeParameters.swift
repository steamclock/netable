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
                throw NetworkAPIError.codingError("Encoding error: Failed to create url parameters dictionary")
            }

            if paramsDict.isEmpty {
                return
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
                throw NetworkAPIError.codingError("Request JSON encoding failed, probably due to an invalid value")
            }
        }
    }
}
