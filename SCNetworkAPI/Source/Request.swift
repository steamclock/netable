//
//  Request.swift
//  SCNetworkAPI
//
//  Created by Brendan Lensink on 2018-10-18.
//  Copyright © 2018 steamclock. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
}

public protocol Request {
    associatedtype Parameters: Encodable
    associatedtype Returning: Decodable
    associatedtype FinalResource

    var method: HTTPMethod { get }
    var path: String { get }
    var parameters: Parameters { get }

    func finalize(raw: Returning) -> Result<FinalResource, NetworkAPIError>
}

public protocol MultipartFormData { }

public protocol UrlEncodedFormData { }

public extension Request where Parameters == Empty {
    var parameters: Parameters {
        return Empty()
    }
}

public struct Empty: Codable {
    public static let data = "{}".data(using: .utf8)!
}

extension URLRequest {
    /**
     Configures the URL request for `multipart/form-data`. The request's `httpBody` is set, and a value is set for the HTTP header field `Content-Type`.

     - Parameter parameters: The form data to set.
     - Parameter encoding: The encoding to use for the keys and values.

     - Throws: `MultipartFormDataEncodingError` if any keys or values in `parameters` are not entirely in `encoding`.

     - Note: The default `httpMethod` is `GET`, and `GET` requests do not typically have a response body. Remember to set the `httpMethod` to e.g. `POST` before sending the request.

     - Seealso: https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#multipart-form-data
     */
    public mutating func setMultipartFormData(_ parameters: [String: String], encoding: String.Encoding) throws {
        let makeRandom = { UInt32.random(in: (.min)...(.max)) }
        let boundary = String(format: "------------------------%08X%08X", makeRandom(), makeRandom())

        let contentType: String = try {
            guard let charset = CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(encoding.rawValue)) else {
                throw MultipartFormDataEncodingError.characterSetName
            }
            return "multipart/form-data; charset=\(charset); boundary=\(boundary)"
            }()
        addValue(contentType, forHTTPHeaderField: "Content-Type")

        httpBody = try {
            var body = Data()

            for (rawName, rawValue) in parameters {
                if !body.isEmpty {
                    body.append("\r\n".data(using: .utf8)!)
                }

                body.append("--\(boundary)\r\n".data(using: .utf8)!)

                guard
                    rawName.canBeConverted(to: encoding),
                    let disposition = "Content-Disposition: form-data; name=\"\(rawName)\"\r\n".data(using: encoding) else {
                        throw MultipartFormDataEncodingError.name(rawName)
                }
                body.append(disposition)

                body.append("\r\n".data(using: .utf8)!)

                guard let value = rawValue.data(using: encoding) else {
                    throw MultipartFormDataEncodingError.value(rawValue, name: rawName)
                }

                body.append(value)
            }

            body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

            return body
            }()
    }
}

public enum MultipartFormDataEncodingError: Error {
    case characterSetName
    case name(String)
    case value(String, name: String)
}

extension URLRequest {
    private func percentEscapeString(_ string: String) -> String {
        var characterSet = CharacterSet.alphanumerics
        characterSet.insert(charactersIn: "-._* ")

        return string
            .addingPercentEncoding(withAllowedCharacters: characterSet)!
            .replacingOccurrences(of: " ", with: "+")
            .replacingOccurrences(of: " ", with: "+", options: [], range: nil)
    }

    public mutating func setUrlEncodedFormData(_ parameters: [String: String]) {
        httpMethod = "POST"

        addValue("application/json, text/plain, */*", forHTTPHeaderField: "Accept")
        addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let parameterArray = parameters.map { arg -> String in
            let (key, value) = arg
            return "\(key)=\(self.percentEscapeString(value))"
        }

        httpBody = parameterArray.joined(separator: "&").data(using: String.Encoding.utf8)
    }
}
