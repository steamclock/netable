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

  init?(stringValue: String) {
    self.stringValue = stringValue
  }

  var intValue: Int?

  init?(intValue: Int) {
    return nil
  }

}

public extension JSONDecoder.KeyDecodingStrategy {

    static let convertFromKebabCase = JSONDecoder.KeyDecodingStrategy.custom({ keys in
             // Should never receive an empty `keys` array in theory.
        let lastKey = keys.last! // If only there was a non-empty array type...
          if lastKey.intValue != nil {
            return lastKey // It's an array key, we don't need to change anything
          }
          // lastKey.stringValue will be, e.g. "FullName"
          let firstLetter = lastKey.stringValue.prefix(1).lowercased()
          let modifiedKey = firstLetter + lastKey.stringValue.dropFirst()
          // Modified string value will be "fullName"
          return MyCodingKey(stringValue: modifiedKey) ?? lastKey
        })
}


