//
//  MockNetworkService.swift
//  Example
//
//  Created by Amy Oulton on 2022-11-23.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation
import Swifter

class MockNetworkService {
    static let shared = MockNetworkService()

    private var server: HttpServer

    private init() {
        server = HttpServer()

        server["/graphql"] = { _ in
           return .ok(self.loadJson(from: "graphqlPosts"))
        }

        server["/posts/new"] = { _ in
                .internalServerError
        }

        server["/posts/all"] = { _ in
             .ok(self.loadJson(from: "posts"))
        }

        server["/user/login"] = { req in
            let login = self.loadJson(from: "login")
            guard let userInfo = self.unwrapJson(from: login) as? [String: String] else {
                return .internalServerError
            }

            let email = self.getValue(params: req.queryParams, value: "email")
            let password = self.getValue(params: req.queryParams, value: "password")

            guard email == userInfo["email"], password == userInfo["password"] else {
                return .unauthorized
            }

            return .ok(login)
        }

        server["/user/profile"] = { _ in
            .ok(self.loadJson(from: "user"))
        }

        server["/version"] = { _ in
            .ok(self.loadJson(from: "version"))
        }

        try! server.start()
    }

    private func loadJson(from path: String) -> HttpResponseBody {
        guard let path = Bundle.main.path(forResource: path, ofType: "json"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe),
            let jsonResult = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves),
            let jsonResult = jsonResult as? Dictionary<String, AnyObject> else {
                fatalError("Failed to load response JSON for: \(path)")
        }

        return .json(jsonResult)
    }

    private func getValue(params: [(String, String)], value: String) -> String? {
        return params.first { $0.0 == value }.map {
            $0.1
        }
    }

    private func unwrapJson(from json: HttpResponseBody) -> Any? {
        guard case .json(let jsonData) = json else {
            return nil
        }
        return jsonData
    }
}
