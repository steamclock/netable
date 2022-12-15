//
//  CustomDecodingStrategy.swift
//  Example
//
//  Created by Amy Oulton on 2022-12-14.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation
import Netable

struct MyCodingKey: CodingKey {

    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }

}

public extension JSONDecoder.KeyDecodingStrategy {

    static let convertFromKebabCase = JSONDecoder.KeyDecodingStrategy.custom({ keys in
        var modifiedKey = ""
        let key = keys.last!
        if key.intValue != nil {
            return key
        }
        let components = key.stringValue.split(separator: "-")

        guard let firstComponent = components.first?.lowercased() else {
            return key
        }
        let trailingComponents = components.dropFirst().map {
                $0.capitalized
        }
        let lowerCamelCaseKey = ([firstComponent] + trailingComponents).joined()

        return MyCodingKey(stringValue: String(lowerCamelCaseKey))!
    })
}
