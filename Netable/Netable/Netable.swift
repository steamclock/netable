//
//  Netable.swift
//  Netable
//
//  Created by Nigel Brooke on 2018-10-17.
//  Copyright © 2020 Steamclock Software. All rights reserved.
//

import Combine
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
#if canImport(QuartzCore)
import QuartzCore
#else
func CACurrentMediaTime() -> TimeInterval {
    return Date.timeIntervalSinceReferenceDate
}
#endif

open class Netable {
    /// The URL session requests are run through.
    private let urlSession: URLSession

    /// The Netable config supplied when creating an instance.
    private let config: Config

    /// The base URL of your api endpoint.
    public var baseURL: URL

    /// Headers to be sent with each request.
    public var headers: [String: String] = [:]

    /// Destination that logs will be printed to during network requests.
    public var logDestination: LogDestination

    /// Settings for if / how retries will be handled
    public var retryConfiguration: RetryConfiguration

    /// Settings for if / how retries will be handled
    private var delayedOperations = DelayedOperations()

    /// Delegate to handle global request errors
    public var requestFailureDelegate: RequestFailureDelegate?

    /// Publisher for global request errors
    private let requestFailureSubject = PassthroughSubject<NetableError, Never>()
    public let requestFailurePublisher: AnyPublisher<NetableError, Never>

    /**
     * Create a new instance of `Netable` with a base URL.
     *
     * - parameter baseURL: The base URL of your endpoint.
     * - parameter config: Configuration such as timeouts and caching policies for the underlying url session.
     * - parameter logDestination: Destination to send request logs to. Default is DefaultLogDestination
     * - parameter retryConfiguration: Configuration for request retry policies
     */
    public init(baseURL: URL, config: Config = Config(), logDestination: LogDestination = DefaultLogDestination(), retryConfiguration: RetryConfiguration = RetryConfiguration()) {
        self.baseURL = baseURL
        self.config = config
        self.logDestination = logDestination
        self.retryConfiguration = retryConfiguration

        self.urlSession = URLSession(configuration: .ephemeral)
        if let timeout = config.timeout {
            self.urlSession.configuration.timeoutIntervalForRequest = timeout
        }

        requestFailurePublisher = requestFailureSubject.eraseToAnyPublisher()

        log(.startupInfo(baseURL: baseURL, logDestination: logDestination))
    }

    /**
     * Create and send a new request, returning a PassthroughSubject to monitor for results.
     *
     * - parameter request: The request to send, this has to extend `Request`.
     *
     * - returns: A PassthroughSubject that will emit a `Result` when the request completes, or a `NetableErorr` on failure.
     */
    public func request<T: Request>(_ request: T) -> PassthroughSubject<T.FinalResource, NetableError> {
        let resultSubject = PassthroughSubject<T.FinalResource, NetableError>()

        self.request(request) { result in
            switch result {
            case .success(let finalResource):
                resultSubject.send(finalResource)
            case .failure(let error):
                resultSubject.send(completion: .failure(error))
            }
        }

        return resultSubject
    }

    /**
     * Create and send a new request.
     *
     * - parameter request: The request to send, this has to extend `Request`.
     * - parameter completion: Your completion handler for the request.
     *
     * - returns: A `RequestIdentifier` you can use to monitor and cancel your request.
     */
    @discardableResult public func request<T: Request>(_ request: T, completion unsafeCompletion: @escaping (Result<T.FinalResource, NetableError>) -> Void) -> RequestIdentifier {
        // Make sure the completion is dispatched on the main thread.
        let completion: (Result<T.FinalResource, NetableError>) -> Void = { result in
            DispatchQueue.main.async {
                unsafeCompletion(result)

                if case .failure(let error) = result {
                    self.requestFailureDelegate?.requestDidFail(request, error: error)
                    self.requestFailureSubject.send(error)
                }
            }
        }

        var urlRequest: URLRequest!
        do {
            let finalURL = try fullyQualifiedURLFrom(path: request.path)
            urlRequest = URLRequest(url: finalURL)
            urlRequest.httpMethod = request.method.rawValue

            guard finalURL.scheme?.lowercased() == "https" || finalURL.scheme?.lowercased() == "http" else {
                self.log(.message("Only HTTP and HTTPS request are supported currently."))
                throw NetableError.malformedURL
            }

            if T.Parameters.self != Empty.self {
                try urlRequest.encodeParameters(for: request, defaultEncodingStrategy: config.jsonEncodingStrategy)
            }
        } catch {
            let netableError = (error as? NetableError) ?? NetableError.unknownError(error)
            log(.requestCreationFailed(urlString: request.path, error: netableError))
            completion(.failure(netableError))
            return RequestIdentifier(id: "invalid", session: self)
        }

        headers.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        return startRequestTask(request, urlRequest: urlRequest, id: UUID().uuidString, retriesLeft: retryConfiguration.count, completion: completion)
    }

    private func startRequestTask<T: Request>(_ request: T, urlRequest: URLRequest, id: String, retriesLeft: UInt, completion: @escaping (Result<T.FinalResource, NetableError>) -> Void) -> RequestIdentifier {
        let startTimestamp = CACurrentMediaTime()

        let requestInfo = LogEvent.RequestInfo(
            urlString:  urlRequest.url?.absoluteString ?? "UNDEFINED",
            method: request.method,
            headers: urlRequest.allHTTPHeaderFields ?? [:]
        )

        log(.requestStarted(request: requestInfo))
        if !config.enableLogRedaction, let params = try? request.parameters.toParameterDictionary(encodingStrategy: request.jsonKeyEncodingStrategy ?? config.jsonEncodingStrategy) {
            log(.requestBody(body: params))
        } else {
            let params = request.unredactedParameters(defaultEncodingStrategy: config.jsonEncodingStrategy)
            log(.requestBody(body: params))
        }

        let retryConfiguration = self.retryConfiguration

        let task = urlSession.dataTask(with: urlRequest) { data, response, error in
            let time = CACurrentMediaTime() - startTimestamp

            do {
                if let error = error {
                    throw NetableError.requestFailed(error)
                }

                guard let response = response as? HTTPURLResponse else { fatalError("Casting response to HTTPURLResponse failed") }

                guard 200...299 ~= response.statusCode else {
                    throw NetableError.httpError(response.statusCode, data)
                }

                let decoded = request.decode(data, defaultDecodingStrategy: self.config.jsonDecodingStrategy)
                switch decoded {
                case .success(let raw):
                    let finalizedData = request.finalize(raw: raw)

                    switch finalizedData {
                    case .success(let finalizedResult):
                        self.log(.requestSuccess(request: requestInfo, taskTime: time, statusCode: response.statusCode, responseData: data, finalizedResult: finalizedResult))
                    case .failure(let finalizedError):
                        throw finalizedError
                    }

                    completion(finalizedData)
                case .failure(let error):
                    throw error
                }
            } catch {
                let netableError = (error as? NetableError) ?? NetableError.unknownError(error)

                var allowRetry = true

                // We totally supress retrying cancels (because then it would be impossible to cancel a request at all)
                // and timeouts (becasue they generally take so long to fail that allowing retries would cause enormous waits,
                // might want to relax this eventually if we know a shorter timeout is in use)
                if case .requestFailed(let error) = netableError {
                    let nsError = error as NSError
                    if nsError.domain == NSURLErrorDomain {
                        if (nsError.code == NSURLErrorCancelled) || (nsError.code == NSURLErrorTimedOut) {
                            allowRetry = false
                        }
                    }
                }

                if allowRetry && retryConfiguration.enabled && retriesLeft > 0 && retryConfiguration.errors.shouldRetry(netableError) {
                    self.log(.requestRetrying(request: requestInfo, taskTime: time, error: netableError))
                    self.delayedOperations.delay(retryConfiguration.delay, withID: id) {
                        _ = self.startRequestTask(request, urlRequest: urlRequest, id: id, retriesLeft: retriesLeft - 1, completion: completion)
                    }
                }
                else {
                    self.log(.requestFailed(request: requestInfo, taskTime: time, error: netableError))
                    completion(.failure(netableError))
                }
            }
        }

        task.taskDescription = id
        task.resume()

        return RequestIdentifier(id: id, session: self)
    }

    /**
     * Cancel a specific ongoing request.
     *
     * - parameter request: The request to cancel.
     */
    open func cancel(byId taskId: RequestIdentifier) {
        guard taskId.session == self else {
          fatalError("Attempted to cancel a task from a different Netable session")
        }

        self.log(.message("Cancelling request by task identifier."))

        if delayedOperations.cancel(taskId.id) {
            self.log(.message("Cancelled delayed retry task."))
            return
        }

        urlSession.getAllTasks { tasks in
            guard let task = tasks.first(where: { $0.taskDescription == taskId.id }) else {
                self.log(.message("Failed to cancel request, no request with that id was found."))
                return
            }
            self.log(.message("Task cancelled."))
            task.cancel()
        }
    }

    /**
     * Cancel any ongoing requests.
     */
    open func cancelAllTasks() {
        delayedOperations.cancelAll()
        
        urlSession.getAllTasks { tasks in
            self.log(.message("Cancelling all ongoing tasks."))
            for task in tasks {
                task.cancel()
            }
        }
    }

    // MARK: Private Helper Functions

    /**
     * Helper function for logging, to avoid having to reference the log destination everywhere and so we can possibly change the semantics of,
     * for example, what thread these are dispatched on later.
     *
     * - parameter event: The event to log
     *
     */
    internal func log(_ event: LogEvent) {
        if Thread.isMainThread {
            self.logDestination.log(event: event)
        } else {
            DispatchQueue.main.async {
                self.logDestination.log(event: event)
            }
        }
    }

    /**
     * Make the provided path into a fully qualified URL. It may be invalid or partially qualified.
     *
     * - parameter path: The request path to qualify.
     *
     * - Throws: `NetableError` if the provided URL is invalid and unable to be corrected.
     *
     * - returns: A fully qualified URL if successful, an `Error` if not.
     */
    internal func fullyQualifiedURLFrom(path: String) throws -> URL {
        // Make sure the url is a well formed path.
        guard let url = URL(string: path) else {
            throw NetableError.malformedURL
        }

        let finalURL: URL

        if url.scheme != nil {
            // Fully qualified URL, check it's okay.
            finalURL = url

            guard finalURL.absoluteString.hasPrefix(baseURL.absoluteString) else {
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

extension Netable: Equatable {
    public static func == (lhs: Netable, rhs: Netable) -> Bool {
        lhs.urlSession == rhs.urlSession
    }
}
