//
//  Netable.swift
//  Netable
//
//  Created by Nigel Brooke on 2018-10-17.
//  Copyright © 2018 steamclock. All rights reserved.
//

import Foundation
import QuartzCore

open class Netable {
    private let urlSession: URLSession

    /// The base URL of your api endpoint.
    public var baseURL: URL

    /// Headers to be sent with each request.
    public var headers: [String: String] = [:]

    /// Destination that logs will be printed to during network requests.
    public var logDestination: LogDestination

    /**
     * Create a new instance of `Netable` with a base URL.
     *
     * - parameter baseURL: The base URL of your endpoint.
     * - parameter configuration: Configuration such as timeouts and caching policies for the underlying url session.
     */
    public init(baseURL: URL, configuration: URLSessionConfiguration = .ephemeral, logDestination: LogDestination = DefaultLogDestination()) {
        self.baseURL = baseURL
        self.urlSession = URLSession(configuration: configuration)
        self.logDestination = logDestination

        logDestination.log(event: .message("""
            Netable instance initiated. Here we go!
                Base URL: Base URL: \(baseURL.absoluteString)
                Log Destination: \(logDestination)
        """))
    }

    /**
     * Create and send a new request.
     *
     * - parameter request: The request to send, this has to extend `Request`.
     * - parameter completion: Your completion handler for the request.
     */
    public func request<T: Request>(_ request: T, completion unsafeCompletion: @escaping (Result<T.FinalResource, NetableError>) -> Void) {
        let completion: (Result<T.FinalResource, NetableError>) -> Void = { result in
            DispatchQueue.main.async {
                unsafeCompletion(result)
            }
        }

        var urlRequest: URLRequest!
        do {
            let finalURL = try fullyQualifiedURLFrom(path: request.path)
            urlRequest = URLRequest(url: finalURL)
            urlRequest.httpMethod = request.method.rawValue

            if T.Parameters.self != Empty.self {
                try urlRequest.encodeParameters(for: request)
            }
        } catch let error as NetableError {
            logDestination.log(event: .requestFailed(error: error))
            completion(.failure(error))
            return
        } catch {
            let unknownError = NetableError.unknownError(error)
            logDestination.log(event: .requestFailed(error: unknownError))
            completion(.failure(unknownError))
            return
        }

        headers.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        let startTimestamp = CACurrentMediaTime()
        logDestination.log(event: .requestStarted(
            urlString:  urlRequest.url?.absoluteString ?? "UNDEFINED",
            method: request.method,
            headers: urlRequest.allHTTPHeaderFields ?? [:],
            params: try? request.parameters.toParameterDictionary())
        )

        let task = urlSession.dataTask(with: urlRequest) { data, response, error in
            defer {
                let endTimestamp = CACurrentMediaTime()

                let userInfo = NetableNotification.userInfo(
                    forRequest: urlRequest,
                    data: data,
                    response: response,
                    duration: endTimestamp - startTimestamp,
                    error: error
                )

                NotificationCenter.default.post(
                    name: Notification.Name.NetableRequestDidComplete,
                    object: self,
                    userInfo: userInfo
                )
            }

            do {
                if let error = error {
                    self.logDestination.log(event: .requestFailed(error: NetableError.requestFailed(error)))
                    throw NetableError.requestFailed(error)
                }

                guard let response = response as? HTTPURLResponse else { fatalError("Casting response to HTTPURLResponse failed") }
                guard 200...299 ~= response.statusCode else {
                    self.logDestination.log(event: .requestCompleted(statusCode: response.statusCode, responseData: data, finalizedResult: nil))
                    throw NetableError.httpError(response.statusCode, data)
                }

                let decoded = request.decode(data)
                switch decoded {
                case .success(let raw):
                    let finalizedData = request.finalize(raw: raw)
                    self.logDestination.log(event: .requestCompleted(statusCode: response.statusCode, responseData: data, finalizedResult: finalizedData))
                    completion(finalizedData)
                case .failure(let error):
                    self.logDestination.log(event: .requestFailed(error: error))
                    completion(.failure(error))
                }
            } catch let error as NetableError {
                self.logDestination.log(event: .requestFailed(error: error))
                completion(.failure(error))
            } catch {
                let error = NetableError.decodingError(error, data)
                self.logDestination.log(event: .requestFailed(error: error))
                completion(.failure(error))
            }
        }

        task.resume()
    }

    /**
     * Cancel any ongoing requests.
     */
    open func cancelAllTasks() {
        urlSession.getAllTasks { tasks in
            self.logDestination.log(event: .message("Cancelling all \(tasks.count) ongoing tasks."))
            for task in tasks {
                task.cancel()
            }
        }
    }

    // MARK: Private Helper Functions

    /**
     * Make the provided path into a fully qualified URL. It may be invalid or partially qualified.
     *
     * - parameter path: The request path to qualify.
     * - parameter enforceServerRequirement: Will cause this function to throw a `wrongServer` error if the path doesn't match the base URL. Defaults to true
     *
     * - Throws: `NetableError` if the provided URL is invalid and unable to be corrected.
     *
     * - returns: A fully qualified URL if successful, an `Error` if not.
     */
    internal func fullyQualifiedURLFrom(path: String, enforceServerRequirement: Bool = true) throws -> URL {
        // Make sure the url is a well formed path.
        guard let url = URL(string: path) else {
            throw NetableError.malformedURL
        }

        let finalURL: URL

        if url.scheme != nil {
            // Fully qualified URL, check it's okay.
            finalURL = url

            if enforceServerRequirement && !finalURL.absoluteString.hasPrefix(baseURL.absoluteString) {
                throw NetableError.wrongServer
            }
        } else {
            // Partially qualified URL, add baseURL.
            guard let combinedURL = URL(string: path, relativeTo: baseURL) else {
                throw NetableError.malformedURL
            }

            finalURL = combinedURL
        }

        return finalURL
    }
}
