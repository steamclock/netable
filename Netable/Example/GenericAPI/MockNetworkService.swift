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

        server["/posts/all"] = { _ in
            .ok(self.loadJson(from: "posts"))
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
}
