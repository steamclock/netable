//
//  UserRequest.swift
//  Example
//
//  Created by Amy Oulton on 2022-11-29.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation
import Netable

struct UserRequest: Request {
    typealias RawResource = SmartUnwrap<User>
    typealias FinalResource = User

    var method: HTTPMethod { return .get }

    var path = "profile"
}
