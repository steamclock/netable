//
//  ContentLoadState.swift
//  NetableExample
//
//  Created by Brendan on 2021-09-03.
//

import Foundation
import Netable

enum ContentLoadState {
    case noData
    case hasData
    case loading
    case error(NetableError)
}
