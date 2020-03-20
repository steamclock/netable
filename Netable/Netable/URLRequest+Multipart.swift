//
//  URLRequest+Multipart.swift
//  Netable
//
//  Created by Jeremy Chiang on 2020-02-04.
//  Copyright © 2020 Steamclock Software. All rights reserved.
//

import Foundation

/// Any errors thrown while encoding `multipart/form-data` infomation will conform to this.
public enum MultipartFormDataEncodingError: Error {
    /// Failed to unwrap character set name from encoding type.
    case characterSetName

    /// Failed to encode a name.
    case name(String)

    /// Failed to encode a value.
    case value(String, name: String)
}

public protocol MultipartFormData { }

extension URLRequest {
    /**
     * Configures the URL request for `multipart/form-data`.
     * The request's `httpBody` is set, and a value is set for the HTTP header field `Content-Type`.
     *
     * - Parameter parameters: The form data to set.
     * - Parameter encoding: The encoding to use for the keys and values.
     *
     * - Throws: `MultipartFormDataEncodingError` if any keys or values in `parameters` are not entirely in `encoding`.
     *
     * - Note: The default `httpMethod` is `GET`, and `GET` requests do not typically have a response body. Remember to set the `httpMethod` to e.g. `POST` before sending the request.
     *
     * - Seealso: https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#multipart-form-data
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
