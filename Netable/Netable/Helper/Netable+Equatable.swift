//
//  Netable+Equatable.swift
//  Netable
//
//  Created by Brendan on 2022-09-28.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation

extension Netable: Equatable {
    public static func == (lhs: Netable, rhs: Netable) -> Bool {
        lhs.urlSession == rhs.urlSession
    }
}
