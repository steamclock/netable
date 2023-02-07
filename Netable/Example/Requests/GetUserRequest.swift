//
//  GetUserRequest.swift
//  Example
//
//  Created by Amy Oulton on 2022-11-29.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation
import Netable

struct GetUserRequest: Request {
    typealias RawResource = SmartUnwrap<User>
    typealias FinalResource = User

    var method: HTTPMethod { .get }
    var smartUnwrapKey = "user"
    var jsonKeyDecodingStrategy: JSONDecoder.KeyDecodingStrategy? { .convertFromKebabCase }
    var path = "user/profile"
    var headers: [String : String]

    func postProcess(result: FinalResource) {
        DataManager.shared.user = result
    }
}
