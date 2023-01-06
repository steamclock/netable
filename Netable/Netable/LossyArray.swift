//
//  LossyArray.swift
//  Netable
//
//  Created by Brendan on 2022-11-30.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation

/// Adapted from https://stackoverflow.com/a/46369152

/// Array container that allows for partial decoding of elements.
/// If an element of the array fails to decode, it will be omitted rather than the rest of the array failing to decode.
public struct LossyArray<Element>: Sendable where Element: Sendable {
    /// All elements of the array that decoded successfully.
    public var elements: [Element]

    public init(elements: [Element]) {
        self.elements = elements
    }
}

extension LossyArray: Decodable where Element: Decodable {
    /// Decode non-optional item into an optional element.
    public struct FailableDecodable<Element: Decodable>: Decodable {
        public var element: Element?

        /// Decode an element and set it to `nil` if decoding fails.
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            element = try? container.decode(Element.self)
        }
    }

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

/// Adapted from: https://kenb.us/lossy-decodable-for-arrays
/// Gives array method access to LossyArray without needing to access the element within.
extension LossyArray: RandomAccessCollection {
    public var startIndex: Int { return elements.startIndex }
    public var endIndex: Int { return elements.endIndex }

    public subscript(_ index: Int) -> Element {
        return elements[index]
    }
}
