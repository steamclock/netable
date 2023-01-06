//
//  SmartUnwrap.swift
//  Netable
//
//  Created by Brendan on 2021-08-27.
//  Copyright © 2021 Steamclock Software. All rights reserved.
//

import Foundation

public struct SmartUnwrap<T: Decodable>: Decodable, Sendable where T: Sendable {
    public typealias DecodedType = T

    public var decodedType: DecodedType
    public var unwrapKey: String?

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

    public init(decodedType: T) {
        self.decodedType = decodedType
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        let smartUnwrapKey = decoder.userInfo[.smartUnwrapKey] as? String

        // If the smartUnwrapKey is set, only try and decode the key with the same name as the smartUnwrapKey.
        if let smartUnwrapKey = smartUnwrapKey, !smartUnwrapKey.isEmpty {
            guard let dynamicKey = DynamicCodingKeys(stringValue: smartUnwrapKey) else {
                throw NetableError.resourceExtractionError("Failed to unwrap type \(T.self) from SmartUnwrap response, couldn't find object with key \(smartUnwrapKey).")
            }

            guard let decoded = try? container.decode(T.self, forKey: dynamicKey) else {
                throw NetableError.resourceExtractionError("Failed to unwrap type \(T.self) from SmartUnwrap response. Couldn't decode object for key \(smartUnwrapKey).")
            }
            decodedType = decoded
        }

        // If there's no smartUnwrapKey set, try and decode each key in the object
        let decodedObjects = container.allKeys
            .compactMap({ key -> T? in
                guard let dynamicKey = DynamicCodingKeys(stringValue: key.stringValue) else {
                    return nil
                }
                return try? container.decode(T.self, forKey: dynamicKey)
            })

        if decodedObjects.isEmpty {
            throw NetableError.resourceExtractionError("Failed to unwrap type \(T.self) from SmartUnwrap response, couldn't decode any objects.")
        }

        guard decodedObjects.count == 1, let decoded = decodedObjects.first else {
            throw NetableError.resourceExtractionError("Failed to unwrap type \(T.self) from SmartUnwrap response, decoded \(decodedObjects.count) objects where only 1 was expected. Try setting a `smartUnwrapKey` to specify a single object.")
        }

        decodedType = decoded
    }
}
