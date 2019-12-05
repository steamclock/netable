//
//  SCNetworkAPI.swift
//  SCNetworkAPI
//
//  Created by Nigel Brooke on 2018-10-17.
//  Copyright © 2018 steamclock. All rights reserved.
//

import Foundation
import os
import QuartzCore

open class NetworkAPI {
    private var urlSession = URLSession(configuration: .ephemeral)

    /// The base URL of your api endpoint.
    public var baseURL: URL

    /// Headers to be sent with each request.
    public var headers: [String: String] = [:]

    /// Toggle output of detailed logs via `NSLog`
    public var consoleLogLevel: NetworkLogLevel {
        didSet {
            log.info("Log level set to \(consoleLogLevel.name).")
            log.logLevel = consoleLogLevel
        }
    }

    /**
     * Create a new instance of `NetworkAPI` with a base URL.
     *
     * - parameter baseURL: The base URL of your endpoint.
     * - parameter logLabel: Optional log level to subscribe to. Defaults to `.none`.
     */
    public init(baseURL: URL, logLevel: NetworkLogLevel = .none) {
        self.baseURL = baseURL
        self.consoleLogLevel = logLevel
        log.info("Created. BaseURL: \(baseURL.absoluteString). Log Level: \(logLevel.name).")
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
            log.info("Request parameter encoding failed: \(error)")
            completion(.failure(error))
        } catch {
            log.info("Request parameter encoding failed: \(error)")
            completion(.failure(.unknownError(error)))
        }

        // Encode headers
        headers.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        // Send the request
        let startTimestamp = CACurrentMediaTime() * 1000

        if let urlString = urlRequest.url?.absoluteString {
            log.info("Request: \(urlString)")
        }

        if let headers = urlRequest.allHTTPHeaderFields {
            log.info("Request headers: \(headers)")
        }

        log.info("Request method: \(request.method.rawValue).")

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
                log.info(userInfo.description)
            }

            do {
                if let error = error {
                    log.info("Request failed: \(error)")
                    throw NetworkAPIError.requestFailed(error)
                }

                guard let responseURLString = response?.url?.absoluteString,
                        let response = response as? HTTPURLResponse else {
                    fatalError("Casting response to HTTPURLResponse failed")
                }

                var debugString = "Response URL: \(responseURLString). Status code: \(response.statusCode)."
                if let headers = response.allHeaderFields as? [String: Any] {
                    debugString += " Headers: \(headers)"
                }
                log.info(debugString)

                guard 200...299 ~= response.statusCode else {
                    throw NetworkAPIError.httpError(response.statusCode, data)
                }

                // Attempt to decode the response if we're expecting one
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601

                if T.RawResource.self == Empty.self {
                    let raw = try decoder.decode(T.RawResource.self, from: Empty.data)
                    let finalized = request.finalize(raw: raw)
                    log.info("Request returned: \(finalized)")
                    completion(finalized)
                } else {
                    guard let data = data else {
                        throw NetworkAPIError.noData
                    }

                    let raw = try decoder.decode(T.RawResource.self, from: data)
                    let finalized = request.finalize(raw: raw)

                    log.info("Request returned: \(finalized)")
                    completion(finalized)
                }
            } catch let error as NetworkAPIError {
                log.info("Request failed: \(error)")
                return completion(.failure(error))
            } catch {
                log.info("Request failed decoding: \(error)")
                completion(.failure(.decodingError(error, data)))
            }
        }

        task.resume()
    }

    /**
     * Cancel any ongoing requests
     */
    open func cancelAllTasks() {
        log.info("Cancelling all requests.")
        urlSession.getAllTasks { tasks in
            for task in tasks {
                log.info("Cancelled \(task.currentRequest?.url?.absoluteString ?? " an ongoing task")")
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
            log.error("Request failed: URL was malformed.")
            throw NetworkAPIError.malformedURL
        }

        let finalURL: URL

        if url.scheme != nil {
            // Fully qualified URL, check it's okay
            finalURL = url

            guard finalURL.absoluteString.hasPrefix(baseURL.absoluteString) else {
                log.error("Request failed: wrong server.")
                throw NetworkAPIError.wrongServer
            }
        } else {
            // Partially qualified URL, add baseURL
            guard let combinedURL = URL(string: path, relativeTo: baseURL) else {
                log.error("Request failed: URL was malformed.")
                throw NetworkAPIError.malformedURL
            }

            finalURL = combinedURL
        }

        return finalURL
    }
}
