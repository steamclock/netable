//
//  User.swift
//  Example
//
//  Created by Amy Oulton on 2022-11-28.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation
import Netable

struct User: Decodable {
    let firstName: String
    let lastName: String
    let location: String
    let bio: String
    let age: Int
    let loginData: LossyArray<UserLoginData>
}

struct UserLoginData: Decodable, Hashable {
    let date: String
    let time: String
    let location: String
}
