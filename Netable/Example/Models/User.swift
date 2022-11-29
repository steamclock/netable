//
//  User.swift
//  Example
//
//  Created by Amy Oulton on 2022-11-28.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation

struct User: Decodable {
    let email: String
    let password: String
    let firstName: String?
    let lastName: String?
    let location: String?
}
