//
//  User.swift
//  NetableExample
//
//  Created by Brendan on 2021-09-02.
//  Copyright © 2021 Steamclock Software. All rights reserved.
//

import Foundation

struct User: Decodable {
    let email: String
    let token: String
    let firstName: String?
    let lastName: String?
    let location: String?
}
