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

public actor Netable {
    /// The URL session requests are run through.
    internal let urlSession: URLSession

    /// The Netable config supplied when creating an instance.
    private let config: Config

    /// The base URL of your api endpoint.
    public let baseURL: URL

    /// Any interceptors to be applied to all outgoing requests.
    public let interceptorList: InterceptorList?

    /// Destination that logs will be printed to during network requests.
    public let logDestination: LogDestination

    /// Settings for if / how retries will be handled
    public let retryConfiguration: RetryConfiguration

    /// Delegate to handle global request errors
    public let requestFailureDelegate: RequestFailureDelegate?

    /// Publisher for global request errors
    private let requestFailureSubject = PassthroughSubject<NetableError, Never>()
    public nonisolated let requestFailurePublisher: AnyPublisher<NetableError, Never>

    /**
     * Create a new instance of `Netable` with a base URL.
     *
     * - parameter baseURL: The base URL of your endpoint.
     * - parameter config: Configuration such as timeouts and caching policies for the underlying url session.
     * - parameter interceptorList: Any interceptors to be applied to all outoing requests.
     * - parameter logDestination: Destination to send request logs to. Default is DefaultLogDestination
     * - parameter retryConfiguration: Configuration for request retry policies
     */
    public init(
            baseURL: URL,
            config: Config = Config(),
            interceptorList: InterceptorList? = nil,
            logDestination: LogDestination = DefaultLogDestination(),
            retryConfiguration: RetryConfiguration = RetryConfiguration(),
            requestFailureDelegate: RequestFailureDelegate? = nil) {
        self.baseURL = baseURL
        self.config = config
        self.interceptorList = interceptorList
        self.logDestination = logDestination
        self.retryConfiguration = retryConfiguration
        self.requestFailureDelegate = requestFailureDelegate

        self.urlSession = URLSession(configuration: .ephemeral)
        if let timeout = config.timeout {
            self.urlSession.configuration.timeoutIntervalForRequest = timeout
        }

        requestFailurePublisher = requestFailureSubject.eraseToAnyPublisher()

        logToMainThread(.startupInfo(baseURL: baseURL, logDestination: logDestination))
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
                await self.log(.message("Only HTTP and HTTPS request are supported currently."))
                throw NetableError.malformedURL
            }

            if T.Parameters.self != Empty.self {
                try urlRequest.encodeParameters(for: request, defaultEncodingStrategy: config.jsonEncodingStrategy)
            }

            config.globalHeaders.forEach { key, value in
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }

            request.headers.forEach { key, value in
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
            let result = try await startRequestTask(
                request,
                urlRequest: urlRequest,
                id: UUID().uuidString
            )
            return try await request.postProcess(result: result)
        } catch {
            let netableError = (error as? NetableError) ?? NetableError.unknownError(error)
            await log(.requestCreationFailed(urlString: request.path, error: netableError))
            self.sendToErrorDelegates(netableError, request: request)
            throw netableError
        }
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
    @available(*, deprecated, message: "Please update to use the new `async`/`await` APIs.")
    @discardableResult
    public nonisolated func request<T: Request>(
        _ request: T,
        completion unsafeCompletion: @escaping @Sendable (Result<T.FinalResource, NetableError>) -> Void
    ) -> Task<(), Never> {
        // We don't need the whole request to run on the main thread, but DO need to make sure the completion does
        let completion: @Sendable (Result<T.FinalResource, NetableError>) -> Void = { result in
            Task { @MainActor in
                unsafeCompletion(result)
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
     * Create and send a new request, returning a tuple containing a reference to the task and a PassthroughSubject to monitor for results.
     * Note that the PassthroughSubject runs on RunLoop.main.
     *
     * - parameter request: The request to send, this has to extend `Request
     *
     * - returns: A tuple that contains a reference to the `Task`, for cancellation, and a PassthroughSubject to monitor for results.
     */
    
    public nonisolated func request<T: Request>(_ request: T) -> (
        task: Task<(), Never>,
        subject: Publishers.ReceiveOn<PassthroughSubject<Result<T.FinalResource, NetableError>, Never>, RunLoop>
    ) {
        let resultSubject = PassthroughSubject<Result<T.FinalResource, NetableError>, Never>()

        let task = Task {
            do {
                let finalResource = try await self.request(request)
                resultSubject.send(.success(finalResource))
            } catch {
                resultSubject.send(.failure(error.netableError))
            }
        }

        return (task: task, subject: resultSubject.receive(on: RunLoop.main))
    }

    private func startRequestTask<T: Request>(
        _ request: T,
        urlRequest: URLRequest,
        id: String
    ) async throws -> T.FinalResource {
        let startTimestamp = CACurrentMediaTime()

        var finalUrlRequest = urlRequest
        var mockedUrl: URL?
        if let interceptorList = self.interceptorList {
            let result = try await interceptorList.applyInterceptors(request: finalUrlRequest, instance: self)
            switch result {
            case .changed(let newRequest): finalUrlRequest = newRequest
            case .mocked(let url): mockedUrl = url
            case .notChanged: break
            }
        }

        let requestInfo = LogEvent.RequestInfo(
            urlString:  finalUrlRequest.url?.absoluteString ?? "UNDEFINED",
            method: request.method,
            headers: finalUrlRequest.allHTTPHeaderFields ?? [:]
        )

        await log(.requestStarted(request: requestInfo))
        if !config.enableLogRedaction, let params = try? request.parameters.toParameterDictionary(encodingStrategy: request.jsonKeyEncodingStrategy ?? config.jsonEncodingStrategy) {
            await log(.requestBody(body: params))
        } else {
            let params = request.unredactedParameters(defaultEncodingStrategy: config.jsonEncodingStrategy)
            await log(.requestBody(body: params))
        }

        let retryConfiguration = self.retryConfiguration

        if let mocked = mockedUrl {
            let data = try Data(contentsOf: mocked)
            return try await finalize(request: request, data: data)
        }

        for retry in 0..<retryConfiguration.count {
            do {
                let (data, response) = try await urlSession.data(for: finalUrlRequest)
                guard let response = response as? HTTPURLResponse else { fatalError("Casting response to HTTPURLResponse failed") }

                guard 200...299 ~= response.statusCode else {
                  throw NetableError.httpError(response.statusCode, data)
                }

                let finalizedResult = try await finalize(request: request, data: data)

                await self.log(.requestSuccess(request: requestInfo, taskTime: CACurrentMediaTime() - startTimestamp, statusCode: response.statusCode, responseData: data, finalizedResult: finalizedResult))

                return finalizedResult
            } catch {
                let netableError = error.netableError
                let time = CACurrentMediaTime() - startTimestamp

                var dontRetry = false

                // We totally suppress retrying cancels (because then it would be impossible to cancel a request at all)
                // and timeouts (because they generally take so long to fail that allowing retries would cause enormous waits,
                // might want to relax this eventually if we know a shorter timeout is in use)
                if case .cancelled = netableError {
                  dontRetry = true
                }

                if dontRetry || !retryConfiguration.errors.shouldRetry(netableError) || retry >= retryConfiguration.count {
                    await self.log(.requestFailed(request: requestInfo, taskTime: time, error: netableError))
                    throw error
                }

                await self.log(.requestRetrying(request: requestInfo, taskTime: time, error: netableError))
                try await Task.sleep(nanoseconds: UInt64(retryConfiguration.delay) * 1_000_000_000)
            }
        }

        throw NetableError.noData
    }

    /// Cancel any ongoing requests.
    public func cancelAllTasks() {
        urlSession.getAllTasks { tasks in
            self.logToMainThread(.message("Cancelling all ongoing tasks."))
            for task in tasks {
                task.cancel()
            }
        }
    }

    // MARK: Private Helper Functions

    private func finalize<T: Request>(request: T, data: Data) async throws -> T.FinalResource {
        let decoded = try await request.decode(data, defaultDecodingStrategy: self.config.jsonDecodingStrategy)
        let finalizedResult = try await request.finalize(raw: decoded)
        return finalizedResult
    }

    /**
     * Helper function for logging, to avoid having to reference the log destination everywhere and so we can possibly change the semantics of,
     * for example, what thread these are dispatched on later.
     *
     * - parameter event: The event to log
     *
     */
    internal func log(_ event: LogEvent) async {
        self.logDestination.log(event: event)
    }

    /**
     * Logs an event on the main thread
     *
     * - parameter event: The event to log
     *
     */
    internal nonisolated func logToMainThread(_ event: LogEvent) {
        Task { @MainActor in
            await log(event)
        }
    }

    internal func sendToErrorDelegates<T: Request>(_ error: NetableError, request: T) {
        Task {
            self.requestFailureSubject.send(error)
            self.requestFailureDelegate?.requestDidFail(request, error: error)
        }
    }
}

extension AnyPublisher: @unchecked Sendable {}
