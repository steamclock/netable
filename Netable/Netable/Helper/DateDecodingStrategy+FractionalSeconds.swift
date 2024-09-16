//
//  DateDecodingStrategy+FractionalSeconds.swift
//
//
//  Created by Maurice Schenk on 2024-09-16.
//

import Foundation

@available(iOS 15, macOS 12, *)
extension JSONDecoder.DateDecodingStrategy {
    static let iso8601withOptionalFractionalSeconds = custom {
        let string = try $0.singleValueContainer().decode(String.self)
        do {
            return try .init(string, strategy: .iso8601withFractionalSeconds)
        } catch {
            return try .init(string, strategy: .iso8601)
        }
    }
}

@available(iOS 15, macOS 12, *)
extension ParseStrategy where Self == Date.ISO8601FormatStyle {
    static var iso8601withFractionalSeconds: Self { .init(includingFractionalSeconds: true) }
}
