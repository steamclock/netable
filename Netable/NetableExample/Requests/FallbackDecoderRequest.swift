//
//  FallbackDecoderRequest.swift
//  NetableExample
//
//  Created by Brendan on 2021-08-31.
//  Copyright © 2021 Steamclock Software. All rights reserved.
//

import Netable

struct Version: Codable {
    let id: String
    let someField: Int
}

struct SimpleVersion: Codable {
    let id: String
}

struct DecoderResult: Decodable {
    let json: Version
}

struct FallbackDecoderResult: Decodable {
    let json: SimpleVersion
}

struct FallbackDecoderRequest: Request {
    typealias Parameters = SimpleVersion
    typealias RawResource = DecoderResult
    typealias FinalResource = Version
    typealias FallbackResource = FallbackDecoderResult

   public var method: HTTPMethod { return .post }
    public var jsonKeyEncodingStrategy: JSONEncoder.KeyEncodingStrategy {
        return .convertToSnakeCase
    }

   public var path: String {
       return "/post"
   }

   public var parameters: SimpleVersion

    public var unredactedParameterKeys: Set<String> {
        ["id"]
    }

    func finalize(raw: DecoderResult) -> Result<Version, NetableError> {
        .success(raw.json)
    }
}
