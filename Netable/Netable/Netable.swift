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
    internal let urlSession: URLSession

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
     * Create and send a new asynchronous request.
     *
     * - parameter request: The request to send, this has to extend `Request`.
     *
     * - Throws: An error of type `NetableError`
     * - returns: Your `FinalResource`
     */
    @discardableResult
    public func request<T: Request>(_ request: T) async throws -> T.FinalResource {
        var urlRequest: URLRequest!

        do {
            let finalURL = try request.path.fullyQualifiedURL(from: baseURL)
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
            throw netableError
        }

        headers.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        return try await startRequestTask(request, urlRequest: urlRequest, id: UUID().uuidString, retriesLeft: retryConfiguration.count)
    }

    /**
     * Create and send a new request using a callback.
     * Under the hood, this will use async/await to dispatch your request and return the result on the main thread.
     *
     * - parameter request: The request to send, this has to extend `Request`.
     * - parameter completion: Your completion handler for the request.
     *
     * - returns: the Task your request is running in, for cancellation
     */
    @discardableResult
    public func request<T: Request>(_ request: T, completion unsafeCompletion: @escaping (Result<T.FinalResource, NetableError>) -> Void) -> Task<(), Never> {
        // We don't need the whole request to run on the main thread, but DO need to make sure the completion does
        let completion: (Result<T.FinalResource, NetableError>) -> Void = { result in
            DispatchQueue.main.async {
                unsafeCompletion(result)

                if case .failure(let error) = result {
                    self.requestFailureDelegate?.requestDidFail(request, error: error)
                    self.requestFailureSubject.send(error)
                }
            }
        }

        let task = Task {
            do {
                let result = try await self.request(request)
                completion(.success(result))
            } catch {
                completion(.failure(error.netableError))
            }
        }

        return task
    }

    /**
     * Create and send a new request, returning a PassthroughSubject to monitor for results.
     *
     * - parameter request: The request to send, this has to extend `Request`.
     *
     * - returns: A PassthroughSubject that will emit a `Result` when the request completes, or a `NetableErorr` on failure.
     */
    public func request<T: Request>(_ request: T) -> (task: Task<(), Never>, subject: PassthroughSubject<T.FinalResource, NetableError>) {
        let resultSubject = PassthroughSubject<T.FinalResource, NetableError>()

        let task = Task {
            do {
                let finalResource = try await self.request(request)
                resultSubject.send(finalResource)
            } catch {
                resultSubject.send(completion: .failure(error.netableError))
            }
        }

        return (task: task, subject: resultSubject)
    }

    private func startRequestTask<T: Request>(_ request: T, urlRequest: URLRequest, id: String, retriesLeft: UInt) async throws -> T.FinalResource {
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

        do {
            if retriesLeft < retryConfiguration.count {
                sleep(UInt32(retryConfiguration.delay))
            }

            let (data, response) = try await urlSession.data(for: urlRequest)

            guard let response = response as? HTTPURLResponse else { fatalError("Casting response to HTTPURLResponse failed") }

            guard 200...299 ~= response.statusCode else {
                throw NetableError.httpError(response.statusCode, data)
            }

            let decoded = try await request.decode(data, defaultDecodingStrategy: self.config.jsonDecodingStrategy)
            let finalizedResult = try await request.finalize(raw: decoded)

            self.log(.requestSuccess(request: requestInfo, taskTime: CACurrentMediaTime() - startTimestamp, statusCode: response.statusCode, responseData: data, finalizedResult: finalizedResult))

            return finalizedResult
        } catch {
            let netableError = error.netableError
            let time = CACurrentMediaTime() - startTimestamp

            var allowRetry = true

            // We totally suppress retrying cancels (because then it would be impossible to cancel a request at all)
            // and timeouts (because they generally take so long to fail that allowing retries would cause enormous waits,
            // might want to relax this eventually if we know a shorter timeout is in use)
            if case .requestFailed(let error) = netableError {
                let nsError = error as NSError
                if nsError.domain == NSURLErrorDomain {
                    if (nsError.code == NSURLErrorCancelled) || (nsError.code == NSURLErrorTimedOut) {
                        allowRetry = false
                    }
                }

                throw netableError
            }

            if allowRetry && retryConfiguration.enabled && retriesLeft > 0 && retryConfiguration.errors.shouldRetry(netableError) {
                self.log(.requestRetrying(request: requestInfo, taskTime: time, error: netableError))
                return try await self.startRequestTask(request, urlRequest: urlRequest, id: id, retriesLeft: retriesLeft - 1)
            } else {
                self.log(.requestFailed(request: requestInfo, taskTime: time, error: netableError))
                throw netableError
            }
        }
    }

    /**
     * Cancel any ongoing requests.
     */
    open func cancelAllTasks() {
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
        Task { @MainActor in
            self.logDestination.log(event: event)
        }
    }
}
