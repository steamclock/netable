//
//  PostRepository.swift
//  NetableExample
//
//  Created by Brendan on 2021-09-03.
//

import Combine
import Foundation
import Netable

class PostRepository {
    static var shared = PostRepository()

    private let netable = Netable(baseURL: URL(string: "http://localhost:8080/post/")!)
}
