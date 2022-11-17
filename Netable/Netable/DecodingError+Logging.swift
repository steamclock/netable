//
//  DecodingError+Logging.swift
//  Netable
//
//  Created by Jennifer Cooper on 2021-08-26.
//  Copyright © 2021 Steamclock Software. All rights reserved.
//

public extension DecodingError {
    func loggableDescription() -> String {
        switch self {
        case DecodingError.dataCorrupted(let context):
            return "Data Corrupt: \(context.debugDescription) \(context.codingPathDescription)"
        case DecodingError.keyNotFound(let key, _):
            return "Key \(key) not found"
        case DecodingError.valueNotFound(let value, let context):
            return "Value \(value) not found: \(context.debugDescription) \(context.codingPathDescription)"
        case DecodingError.typeMismatch(let type, let context):
            return "Type \(type) mismatch: \(context.debugDescription) \(context.codingPathDescription)"
        default:
            return localizedDescription
        }
    }
}

public extension DecodingError.Context {
    var codingPathDescription: String {
        // Drop first "Index 0" coding key as it's not helpful for describing the coding path
        let stringValues = codingPath.dropFirst().map { $0.stringValue }.joined(separator: ", ")
        return "Path: " + stringValues
    }
}
