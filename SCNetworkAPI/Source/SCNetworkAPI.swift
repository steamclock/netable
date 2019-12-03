//
//  SCNetworkAPI.swift
//  SCNetworkAPI
//
//  Created by Nigel Brooke on 2018-10-17.
//  Copyright © 2018 steamclock. All rights reserved.
//

import Foundation
import QuartzCore

open class NetworkAPI {
    private var urlSession = URLSession(configuration: .ephemeral)

    /// The base URL of your api endpoint.
    public var baseURL: URL

    /// Headers to be sent with each request.
    public var headers: [String: String] = [:]

    /**
     * Create a new instance of `NetworkAPI` with a base URL.
     *
     * - parameter baseURL: The base URL of your endpoint.
     */
    public init(baseURL: URL) {
        self.baseURL = baseURL
    }

    /**
     * Create and send a new request.
     *
     * - parameter request: The request to send, this has to extend `Request`.
     * - parameter completion: Your completion handler for the request.
     */
    public func request<T: Request>(_ request: T, completion unsafeCompletion: @escaping (Result<T.FinalResource, NetworkAPIError>) -> Void) {
        // Make sure the completion is dispatched on the main thread
        let completion: (Result<T.FinalResource, NetworkAPIError>) -> Void = { result in
            DispatchQueue.main.async {
                unsafeCompletion(result)
            }
        }

        // Make sure the provided path is a fully qualified URL, if not try to make it one
        var urlRequest: URLRequest!
        do {
            let finalURL = try fullyQualifiedURLFrom(path: request.path)
            urlRequest = URLRequest(url: finalURL)
            urlRequest.httpMethod = request.method.rawValue

            // Encode request parameters
            if T.Parameters.self != Empty.self {
                try urlRequest.encodeParameters(for: request)
            }
        } catch let error as NetworkAPIError {
            completion(.failure(error))
        } catch {
            completion(.failure(.unknownError(error)))
        }

        // Encode headers
        headers.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        // Send the request
        let startTimestamp = CACurrentMediaTime() * 1000

        let task = urlSession.dataTask(with: urlRequest) { data, response, error in
            defer {
                let endTimestamp = CACurrentMediaTime() * 1000

                let userInfo = NetworkAPI.userInfo(
                    forRequest: urlRequest,
                    data: data,
                    response: response,
                    duration: endTimestamp - startTimestamp,
                    error: error
                )

                NotificationCenter.default.post(
                    name: Notification.Name.NetworkAPIRequestDidComplete,
                    object: self,
                    userInfo: userInfo
                )
            }

            do {
                if let error = error {
                    throw NetworkAPIError.requestFailed(error)
                }

                guard let response = response as? HTTPURLResponse else { fatalError("Casting response to HTTPURLResponse failed") }

                guard 200...299 ~= response.statusCode else {
                    throw NetworkAPIError.httpError(response.statusCode, data)
                }

                // Attempt to decode the response if we're expecting one
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601

                if T.RawResource.self == Empty.self {
                    let raw = try decoder.decode(T.RawResource.self, from: Empty.data)
                    completion(request.finalize(raw: raw))
                } else {
                    guard let data = data else {
                        throw NetworkAPIError.noData
                    }

                    let raw = try decoder.decode(T.RawResource.self, from: data)
                    completion(request.finalize(raw: raw))
                }
            } catch let error as NetworkAPIError {
                return completion(.failure(error))
            } catch {
                completion(.failure(.decodingError(error, data)))
            }
        }

        task.resume()
    }

    /**
     * Cancel any ongoing requests
     */
    open func cancelAllTasks() {
        urlSession.getAllTasks { tasks in
            for task in tasks {
                task.cancel()
            }
        }
    }

    // MARK: Utility

    /**
     * Encode user info from a successful network request to send through `NotificationCenter`
     *
     * - parameter request: The request that triggered this response
     * - parameter data: Any data supplied by the request response
     * - parameter response: The request response
     * - parameter error: The request error if applicable
     *
     * - returns: The user info encoded as a `Dictionary<String, Any>`
     */
    static func userInfo(forRequest request: URLRequest?, data: Data?, response: URLResponse?, duration: CFTimeInterval?, error: Swift.Error?) -> [String: Any] {
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

        if let duration = duration {
            userInfo[Notification.NetworkAPI.duration] = duration
        }

        if let error = error {
            userInfo[Notification.NetworkAPI.responseError] = error
        }

        return userInfo
    }

    // MARK: Private Helper Functions

    /**
     * Make the provided path into a fully qualified URL. It may be invalid or partially qualified.
     *
     * - parameter path: The request path to qualify.
     *
     * - returns: A fully qualified URL if successful, an `Error` if not.
     */
    internal func fullyQualifiedURLFrom(path: String) throws -> URL {
        // Make sure the url is a well formed path
        guard let url = URL(string: path) else {
            throw NetworkAPIError.malformedURL
        }

        let finalURL: URL

        if url.scheme != nil {
            // Fully qualified URL, check it's okay
            finalURL = url

            guard finalURL.absoluteString.hasPrefix(baseURL.absoluteString) else {
                throw NetworkAPIError.wrongServer
            }
        } else {
            // Partially qualified URL, add baseURL
            guard let combinedURL = URL(string: path, relativeTo: baseURL) else {
                throw NetworkAPIError.malformedURL
            }

            finalURL = combinedURL
        }

        return finalURL
    }
}

/**
 * Log an error to the console for debugging.
 *
 * - parameter closure: The error message to log.
 * - parameter functionName: The name of the function that this was called from.
 * - parameter filename: The name of the file this was called from.
 * - parameter lineNumber: The line number this was called from.
 */
private func debugLogError(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
    #if DEBUG
    let message = closure() ?? ""
    NSLog("\(fileName):\(lineNumber) \(functionName) \(message)")
    #endif
}
