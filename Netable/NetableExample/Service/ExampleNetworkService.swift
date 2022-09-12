//
//  ExampleNetworkService.swift
//  NetableExample
//
//  Created by Brendan on 2021-09-03.
//

import Foundation
import Swifter

class ExampleNetworkService {
    static let shared = ExampleNetworkService()

    private var server: HttpServer

    private init() {
        server = HttpServer()

        server["/user/login"] = { _ in
            .ok(self.loadJson(from: "login"))
        }

        server["/user/me"] = { _ in
            .ok(self.loadJson(from: "user"))
        }

        server["/user/unauthorized"] = { _ in
            .unauthorized
        }

        server["/user/failed"] = { _ in
            .internalServerError
        }

        server["/posts/all"] = { _ in
            .ok(self.loadJson(from: "posts"))
        }

        server["/posts/create"] = { _ in
            .ok(self.loadJson(from: "createPost"))
        }

        server["/posts/version"] = { _ in
            .ok(self.loadJson(from: "version"))
        }

        server["/graphql"] = { resp in
            return .ok(self.loadJson(from: "posts"))
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
}
