//
//  Error.swift
//  Netable
//
//  Created by Jeremy Chiang on 2019-04-08.
//  Copyright © 2018 Steamclock Software. All rights reserved.
//

import Foundation

/// All errors returned by Netable are NetableErrors.
public enum NetableError: Error {
    /// Something went wrong while encoding request parameters.
    case codingError(String)

    /// Something went wrong while decoding the response.
    case decodingError(Error, Data?)

    /// The request was successful, but returned a non-200 status code.
    case httpError(Int, Data?)

    /// The URL provided isn't properly formatted.
    case malformedURL

    /// Request failed to complete, usually due to a connectivity problem.
    case requestFailed(Error)

    /// The fully qualified URL's server does not match the base URL.
    /// Something's gone wrong while validating the URL.
    case wrongServer

    /// The server response was expected to contain data but is instead empty.
    case noData

    /// Something went wrong while trying to parse response data.
    /// Throw this error if something goes wrong while calling Request.finalize().
    case resourceExtractionError(String)

    /// We're not sure what went wrong, but something did.
    case unknownError(Error)
}

extension NetableError: LocalizedError {
    public var errorCode: Int? {
        switch self {
        case .codingError:
            return 0
        case .decodingError:
            return 1
        case .httpError(let statusCode, _):
            return statusCode < 100 ? 2 : statusCode
        case .malformedURL:
            return 3
        case .requestFailed:
            return 4
        case .wrongServer:
            return 5
        case .noData:
            return 6
        case .resourceExtractionError:
            return 7
        case .unknownError:
            return 8
        }
    }

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
