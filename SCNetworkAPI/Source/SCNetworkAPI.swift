//
//  SCNetworkAPI.swift
//  SCNetworkAPI
//
//  Created by Nigel Brooke on 2018-10-17.
//  Copyright © 2018 steamclock. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
}

public enum Result<Value> {
    case success(Value)
    case failure(Error)
}

open class NetworkAPI {
    public enum Error: Swift.Error {
        case httpError(Int)
        case malformedURL
        case wrongServer
        case noData
    }

    private var urlSession = URLSession(configuration: .ephemeral)
    public var baseURL: URL
    public var headers: [String: String] = [:]

    public init(baseURL: URL) {
        self.baseURL = baseURL
    }

    public func request<T: Request>(_ request: T, completion unsafeCompletion: @escaping (Result<T.Returning>) -> Void) {
        let completion: (Result<T.Returning>) -> Void = { result in
            DispatchQueue.main.async {
                unsafeCompletion(result)
            }
        }

        guard let url = URL(string: request.path) else {
            completion(.failure(Error.malformedURL))
            return
        }

        // Check if URL is a partial path or fully qualified, and make it fully qualified if it is partial
        let finalURL: URL

        if url.scheme != nil {
            // Fully qualified URL, check it's okay
            finalURL = url

            guard finalURL.absoluteString.hasPrefix(baseURL.absoluteString) else {
                completion(.failure(Error.wrongServer))
                return
            }
        } else {
            // Partially qualified URL, add baseURL
            guard let combinedURL = URL(string: request.path, relativeTo: baseURL) else {
                completion(.failure(Error.malformedURL))
                return
            }

            finalURL = combinedURL
        }

        var urlRequest = URLRequest(url: finalURL)
        urlRequest.httpMethod = request.method.rawValue

        if T.Parameters.self != Empty.self {
            if request.method == .get {
                fatalError("No support for URL encoded parameters on GET requests yet")
            }

            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

            do {
                urlRequest.httpBody = try JSONEncoder().encode(request.parameters)
            } catch {
                debugLogError("Encoding error: \(error)")
                completion(.failure(error))
            }
        }

        headers.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        let task = urlSession.dataTask(with: urlRequest) { data, response, error in
            do {
                if let error = error {
                    throw error
                }

                guard let response = response as? HTTPURLResponse else { fatalError("Casting response to HTTPURLResponse failed") }

                if response.statusCode / 100 != 2 {
                    throw Error.httpError(response.statusCode)
                }

                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601

                if T.Returning.self == Empty.self {
                    completion(.success(try decoder.decode(T.Returning.self, from: Empty.data)))
                } else {
                    guard let data = data else {
                        throw Error.noData
                    }

                    completion(.success(try decoder.decode(T.Returning.self, from: data)))
                }
            } catch {
                debugLogError("Decoding error: \(error)")
                completion(.failure(error))
            }

            let userInfo = NetworkAPI.userInfo(forRequest: urlRequest, data: data, response: response, error: error)
            NotificationCenter.default.post(name: Notification.Name.NetworkAPIRequestDidComplete, object: self, userInfo: userInfo)
        }

        task.resume()
    }

    open func cancelAllTasks() {
        urlSession.getAllTasks { tasks in
            for task in tasks {
                task.cancel()
            }
        }
    }

    // MARK: Utility
    static func userInfo(forRequest request: URLRequest?, data: Data?, response: URLResponse?, error: Swift.Error?) -> [String: Any] {
        var userInfo: [String: Any] = [:]

        if let request = request {
            userInfo[Notification.NetworkAPI.request] = request
        }

        if let data = data {
            userInfo[Notification.NetworkAPI.responseData] = data
        }

        if let response = response {
            userInfo[Notification.NetworkAPI.response] = response
        }

        if let error = error {
            userInfo[Notification.NetworkAPI.responseError] = error
        }

        return userInfo
    }
}

private func debugLogError(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
    #if DEBUG
    let message = closure() ?? ""
    NSLog("\(fileName):\(lineNumber) \(functionName) \(message)")
    #endif
}
