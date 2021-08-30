//
//  SmartUnwrap.swift
//  Netable
//
//  Created by Brendan on 2021-08-27.
//  Copyright © 2021 Steamclock Software. All rights reserved.
//

import Foundation

public class SmartUnwrap<Value: Decodable> {
    public var value: Value

    public init(_ value: Value) {
        self.value = value
    }
}
