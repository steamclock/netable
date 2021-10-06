//
//  GetUserDetailsRequest.swift
//  NetableExample
//
//  Created by Brendan on 2021-09-14.
//  Copyright © 2021 Steamclock Software. All rights reserved.
//

import Netable

struct UserDetailsParams: Encodable {
    let email: String
    let token: String
}

struct GetUserDetailsRequest: Request {
    typealias Parameters = UserDetailsParams
    typealias RawResource = SmartUnwrap<User>
    typealias FinalResource = User

    var method = HTTPMethod.get

    var path = "me"

    var parameters: UserDetailsParams
}
