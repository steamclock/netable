//
//  Error.swift
//  Netable
//
//  Created by Jeremy Chiang on 2019-04-08.
//  Copyright © 2018 steamclock. All rights reserved.
//

import Foundation

public enum NetableError: Error {
    case codingError(String)
    case decodingError(Error, Data?)
    case httpError(Int, Data?)
    case malformedURL
    case requestFailed(Error)
    case wrongServer
    case noData
    case resourceExtractionError(String)
    case unknownError(Error)
}

extension NetableError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .codingError(let message):
            return "Coding error: \(message)"
        case .decodingError(let error, _):
            return "Decoding error: \(error.localizedDescription)"
        case .httpError(let statusCode, _):
            return "HTTP status code: \(statusCode)"
        case .malformedURL:
            return "Malformed URL"
        case .requestFailed(let error):
            return "Request failed: \(error.localizedDescription)"
        case .wrongServer:
            return "Wrong server"
        case .noData:
            return "No data"
        case .resourceExtractionError(let message):
            return "Resource Extraction Error: The raw result could not be turned into the final resource: \(message)"
        case .unknownError(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}

extension NetableError: Equatable {
    public static func == (lhs: NetableError, rhs: NetableError) -> Bool {
        switch (lhs, rhs) {
        case (.codingError(let lhsMessage), .codingError(let rhsMessage)):
            return lhsMessage == rhsMessage
        case (.decodingError(let lhsError, let lhsData), .decodingError(let rhsError, let rhsData)):
            return lhsError.localizedDescription == rhsError.localizedDescription && lhsData == rhsData
        case (.httpError(let lhsCode, let lhsData), .httpError(let rhsCode, let rhsData)):
            return lhsCode == rhsCode && lhsData == rhsData
        case (.malformedURL, .malformedURL):
            return true
        case (.requestFailed(let lhsError), .requestFailed(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.wrongServer, .wrongServer):
            return true
        case (.noData, .noData):
            return true
        case (.resourceExtractionError(let lhsMessage), .resourceExtractionError(let rhsMessage)):
            return lhsMessage == rhsMessage
        case (.unknownError(let lhsError), .unknownError(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}
