//
//  LossyArray.swift
//  Netable
//
//  Created by Brendan on 2022-11-30.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation

/// Adapted from https://stackoverflow.com/a/46369152

/// Decodable a non-optional item into an optional element.
public struct FailableDecodable<Element: Decodable>: Decodable {
    public var element: Element?

    /// Decode an element and set it to `nil` if decoding fails.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        element = try? container.decode(Element.self)
    }
}

/// Array container that allows for partial decoding of elements.
/// If an element of the array fails to decode, it will be ommited rather than the rest of the array failing to decode.
public struct LossyArray<Element: Decodable>: Decodable {
    /// All elements of the array that decoded successfully.
    public let elements: [Element]

    /// Attempt to decode the contents of an array, omitting any results that fail to decode.
    public init(from decoder: Decoder) throws {
        var elements = [Element?]()
        var container = try decoder.unkeyedContainer()
        while !container.isAtEnd {
            let item = try container.decode(FailableDecodable<Element>.self).element
            elements.append(item)
        }
        self.elements = elements.compactMap { $0 }
    }
}
