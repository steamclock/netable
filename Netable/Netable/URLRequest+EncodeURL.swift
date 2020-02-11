//
//  URLRequest+EncodeURL.swift
//  Netable
//
//  Created by Jeremy Chiang on 2020-02-04.
//  Copyright © 2020 Steamclock Software. All rights reserved.
//

import Foundation

public protocol UrlEncodedFormData { }

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
