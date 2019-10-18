//
//  Error.swift
//  SCNetworkAPIMobile
//
//  Created by Jeremy Chiang on 2019-04-08.
//

import Foundation

public enum NetworkAPIError: Error {
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

extension NetworkAPIError: LocalizedError {
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
            return "Resource Conversion Error: The raw result could not be turned into the final resource: \(message)"
        case .unknownError(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}
