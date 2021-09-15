//
//  SwifterManager.swift
//  NetableExample
//
//  Created by Brendan on 2021-09-03.
//

import Foundation
import Swifter

class SwifterManager {
    static let shared = SwifterManager()

    private var server: HttpServer

    private init() {
        server = HttpServer()

        print(loadJson(from: "login"))

        server["/user/login"] = { _ in
            .ok(self.loadJson(from: "login"))
        }

        server["/user/me"] = { _ in
            .ok(self.loadJson(from: "user"))
        }

        server["/post/all"] = { _ in
            .ok(self.loadJson(from: "posts"))
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
