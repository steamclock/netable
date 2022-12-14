//
//  ArrayDecodeStrategy.swift
//  Netable
//
//  Created by Brendan on 2022-12-06.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation

/// Strategy to use when decoding top-level arrays of values
/// By default, if you try to decode an array objects and one of the objects fails to decode, the entire array fails to decode.
/// Instead, this allows you to partially decode arrays and only return the well-formed elements.
/// For lossy decoding nested arrays, we recommend checking out [Better Codable](https://github.com/marksands/BetterCodable).
public enum ArrayDecodeStrategy {
    /// If any element of the array fails to decode, the whole array fails.
    case standard
    /// Decode the array, omitting any elements that fail to decode.
    case lossy
}
