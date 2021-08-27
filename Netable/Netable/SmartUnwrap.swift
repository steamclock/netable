//
//  SmartUnwrap.swift
//  Netable
//
//  Created by Brendan on 2021-08-27.
//  Copyright © 2021 Steamclock Software. All rights reserved.
//

import Foundation

public class SmartUnwrap<Value: Decodable> {
    var value: Value

    init(_ value: Value) {
        self.value = value
    }
}

public protocol SmartUnwrapper {
    associatedtype Value: Decodable
    var smartUnwrap: SmartUnwrap<Value> { get }
}

extension SmartUnwrap: SmartUnwrapper {
    public var smartUnwrap: SmartUnwrap<Value> { return self}
}
