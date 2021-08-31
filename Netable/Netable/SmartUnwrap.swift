//
//  SmartUnwrap.swift
//  Netable
//
//  Created by Brendan on 2021-08-27.
//  Copyright © 2021 Steamclock Software. All rights reserved.
//

import Foundation

public struct SmartUnwrap<T: Decodable>: Decodable {
    public typealias DecodedType = T

    public var decodedType: DecodedType

    private struct DynamicCodingKeys: CodingKey {
        var stringValue: String
        var intValue: Int?

        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        init?(intValue: Int) {
            return nil
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)

        guard let decoded = container.allKeys
                .compactMap({ key -> T? in
                    guard let dynamicKey = DynamicCodingKeys(stringValue: key.stringValue) else {
                        return nil
                    }
                    return try? container.decode(T.self, forKey: dynamicKey)
                }).first else {
            throw NetableError.resourceExtractionError("Failed to unwrap type \(T.self) from SmartUnwrap response.")
        }

        decodedType = decoded
    }
}
