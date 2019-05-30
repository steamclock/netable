//
//  URLRequest+EncodeParameters.swift
//  SCNetworkAPIMobile
//
//  Created by Brendan Lensink on 2018-10-26.
//

import Foundation

extension Encodable {
    func toParameterDictionary() throws -> [String: String] {
        do {
            let paramsData = try JSONEncoder().encode(self)

            guard
                let params = try? JSONSerialization.jsonObject(with: paramsData),
                let paramsDictionary = params as? [String: Any]
                else {
                    throw NetworkAPIError.codingError("Failed to unwrap parameter dictionary")
            }

            // Make sure that our encoded dictionary doesn't contain any nested collections
            for (_, value) in paramsDictionary where
                (value as? [Any]) != nil ||
                    (value as? [AnyHashable: Any]) != nil {
                        throw NetworkAPIError.codingError("Cannot encode nested collections")
            }

            // Convert anything that isn't a string to a string
            let stringsOnlyDictionary: [String: String] = paramsDictionary.mapValues { value -> String in
                "\(value)"
            }

            return stringsOnlyDictionary
        } catch {
            throw NetworkAPIError.codingError(error.localizedDescription)
        }
    }
}

extension URLRequest {
    mutating func encodeParameters<T: Request>(for request: T) throws {
        switch request.method {
        case .get:
            do {
                guard
                    let url = url,
                    var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
                    else {
                        throw NetworkAPIError.codingError("Encoding Error: Failed to unwrap url components")
                }

                let paramsDictionary = try request.parameters.toParameterDictionary()

                components.queryItems = paramsDictionary.map {
                    URLQueryItem(name: $0, value: $1)
                }

                self.url = components.url
            } catch {
                throw NetworkAPIError.codingError("Encoding Error: Failed to create url parameters: \(error)")
            }
        case .post:
            do {
                let paramsDictionary = try request.parameters.toParameterDictionary()

                if request is MultipartFormData {
                    try setMultipartFormData(paramsDictionary, encoding: .utf8)
                } else if request is UrlEncodedFormData {
                    setUrlEncodedFormData(paramsDictionary)
                } else {
                    fallthrough
                }
            } catch {
                throw NetworkAPIError.codingError("Encoding Error: Failed to create request body: \(error.localizedDescription)")
            }
        default:
            setValue("application/json", forHTTPHeaderField: "Content-Type")

            do {
                httpBody = try JSONEncoder().encode(request.parameters)
            } catch {
                throw NetworkAPIError.codingError("Encoding Error: Failed to create request body: \(error.localizedDescription)")
            }
        }
    }
}
