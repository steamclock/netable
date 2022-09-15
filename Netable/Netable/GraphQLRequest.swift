//
//  GraphQLRequest.swift
//  Netable
//
//  Created by Brendan on 2022-09-12.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation

/// Specify how to retrieve the GraphQL query for a request
public enum GraphQLQuerySource {
    /// Autogenerate resource file from dynamic class name (risky)
    /// This functionality checks the name of the request and uses `type(of: self)` to find a .graphql file with the same name in the bundle.
    case autoResource

    /// An arbitrary file URL
    case file(URL)

    /// The full text string of the query
    case literal(String)

    /// The name of a .graphql file in the app bundle
    /// You don't need to include the file extension when specifying a resource.
    case resource(String)
}

/*
*   This helper protocol provides a set of shared methods used by `GraphQLQuery` and `GraphQLMutation`.
*   You'll likely want to sub-class those protocols instead of this one.
*/
public protocol GraphQLRequest: Request {
    associatedtype Parameters = [String: String]

    var source: GraphQLQuerySource { get }
}

public extension GraphQLRequest {
    var method: HTTPMethod { HTTPMethod.post }

    var path: String { "" }

    func getGraphQLQueryContents() -> String {
        switch source {
        case .autoResource: return getAutoResourcedContents()
        case .file(let url): return getFileContents(url)
        case .literal(let literal): return literal
        case .resource(let bundleResource): return getResourcedContents(bundleResource)
        }
    }

    private func getFileContents(_ url: URL) -> String {
        guard let params = try? String(contentsOf: url) else {
            fatalError("Failed to retrieve .graphql file by URL \(url.absoluteString) for request: \(type(of: self)).")
        }
        return params
    }

    private func getAutoResourcedContents() -> String {
        guard let autoResource = "\(type(of: self))".split(separator: ".").last else {
            fatalError("Failed to retrieve auto-resourced .graphql file for request: \(type(of: self)).")
        }

        return getResourcedContents(String(autoResource))
    }

    private func getResourcedContents(_ resource: String) -> String {
        guard let resourcePath = Bundle.main.path(forResource: String(resource), ofType: "graphql"),
                let params = try? String(contentsOfFile: resourcePath) else {
            fatalError("Failed to retrieve .graphql file for request: \(type(of: self)).")
        }
        print("123")
        print(params)

        return params
    }
}

