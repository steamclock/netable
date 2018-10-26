//
//  SCNetworkAPIMobileTests.swift
//  SCNetworkAPIMobileTests
//
//  Created by Brendan Lensink on 2018-10-19.
//

import Mockingjay
import enum SCNetworkAPI.HTTPMethod
@testable import SCNetworkAPI
import XCTest

//swiftlint:disable nesting
class SCNetworkAPIMobileTests: XCTestCase {
    var api: NetworkAPI!
    let baseURL = "https://www.steamclock.com"

    override func setUp() {
        super.setUp()
        api = NetworkAPI(baseURL: URL(string: baseURL)!)
    }

    override func tearDown() {
        super.tearDown()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - fullyQualifiedURLFrom(path: String) Tests

    func testFullyQualifiedURLIsUnchanged() {
        let url = try? api.fullyQualifiedURLFrom(path: baseURL)
        XCTAssert(url?.absoluteString == baseURL)
    }

    func testPartialURLToFullyQualifiedWithSlash() {
        let path = "/test"
        let url = try? api.fullyQualifiedURLFrom(path: path)
        XCTAssert(url?.absoluteString == baseURL + "/test")
    }

    func testPartialURLToFullyQualifiedNoSlash() {
        let path = "test"
        let url = try? api.fullyQualifiedURLFrom(path: path)
        XCTAssert(url?.absoluteString == baseURL + "/test")
    }

    func testInvalidURLDelimReturnsError() {
        XCTAssertThrowsError(try api.fullyQualifiedURLFrom(path: "<")) { error in
            //swiftlint:disable:next force_cast
            XCTAssertEqual(error as! NetworkAPI.Error, NetworkAPI.Error.malformedURL)
        }
    }

    func testInvalidURLControlCharacterReturnsError() {
        XCTAssertThrowsError(try api.fullyQualifiedURLFrom(path: "\(UnicodeScalar(00)!)")) { error in
            //swiftlint:disable:next force_cast
            XCTAssertEqual(error as! NetworkAPI.Error, NetworkAPI.Error.malformedURL)
        }
    }

    func testInvalidURLSpaceReturnsError() {
        XCTAssertThrowsError(try api.fullyQualifiedURLFrom(path: "\(UnicodeScalar(20)!)")) { error in
            //swiftlint:disable:next force_cast
            XCTAssertEqual(error as! NetworkAPI.Error, NetworkAPI.Error.malformedURL)
        }
    }

    func testFullURLBaseDoesntMatchErrors() {
        XCTAssertThrowsError(try api.fullyQualifiedURLFrom(path: "https://www.google.com")) { error in
            //swiftlint:disable:next force_cast
            XCTAssertEqual(error as! NetworkAPI.Error, NetworkAPI.Error.wrongServer)
        }
    }

    // MARK: - Parameter Encoding Tests

    func testGETCatchesEmptyParameters() {
        struct TestGETRequest: Request {
            typealias Parameters = [String: String]
            typealias Returning = Empty

            public var method: HTTPMethod { return .get }
            public var path: String {
                return "test"
            }

            public var parameters: [String: String] {
                return [:]
            }
        }
        var urlRequest = URLRequest(url: URL(string: "https://www.steamclock.com")!)
        XCTAssertThrowsError(try urlRequest.encodeParameters(for: TestGETRequest())) { error in
            //swiftlint:disable:next force_cast
            XCTAssertEqual(error as! NetworkAPI.Error, NetworkAPI.Error.codingError("Parameters is empty"))
        }
    }

    func testGETEncodesEscapedCharacters() {
        struct TestGETRequest: Request {
            typealias Parameters = [String: String]
            typealias Returning = Empty

            public var method: HTTPMethod { return .get }
            public var path: String {
                return "test"
            }

            public var parameters: [String: String] {
                return ["type": "!*'();:@&=+$,/?#[] "]
            }
        }
        var urlRequest = URLRequest(url: URL(string: "https://www.steamclock.com")!)
        try? urlRequest.encodeParameters(for: TestGETRequest())

        guard let url = urlRequest.url else {
            XCTFail("Failed to unwrap url from GET request")
            return
        }
        XCTAssert(url.absoluteString == "https://www.steamclock.com?type=!*'();:@%26%3D+$,/?%23%5B%5D%20")
    }

    func testGETRequest() {
        struct TestGETRequest: Request {
            typealias Parameters = [String: String]
            typealias Returning = Empty

            public var method: HTTPMethod { return .get }
            public var path: String {
                return "test"
            }

            public var parameters: [String: String] {
                return ["type": "test"]
            }
        }
        var urlRequest = URLRequest(url: URL(string: "https://www.steamclock.com")!)
        try? urlRequest.encodeParameters(for: TestGETRequest())

        guard let url = urlRequest.url else {
            XCTFail("Failed to unwrap url from GET request")
            return
        }

        XCTAssert(url.absoluteString == "https://www.steamclock.com?type=test")
    }

    func testPOSTContentTypeIsJSON() {
        struct TestPOSTRequest: Request {
            typealias Parameters = [String: String]
            typealias Returning = Empty

            public var method: HTTPMethod { return .post }
            public var path: String {
                return "test"
            }

            public var parameters: [String: String] {
                return ["type": "test"]
            }
        }

        var urlRequest = URLRequest(url: URL(string: "https://www.steamclock.com")!)
        try? urlRequest.encodeParameters(for: TestPOSTRequest())

        guard let headers = urlRequest.allHTTPHeaderFields,
                let contentType = headers["Content-Type"] else {
            XCTFail("POST Content Type header not defined")
            return
        }

        XCTAssert(contentType == "application/json")
    }

    func testPOSTEncodingCatchesEncodingError() {
        struct TestRequest: Request {
            typealias Parameters = [String: Double]
            typealias Returning = Empty

            public var method: HTTPMethod { return .post }
            public var path: String {
                return "test"
            }

            public var parameters: [String: Double] {
                return ["type": Double.infinity]
            }
        }

        var urlRequest = URLRequest(url: URL(string: "https://www.steamclock.com")!)
        XCTAssertThrowsError(try urlRequest.encodeParameters(for: TestRequest())) { error in
            //swiftlint:disable:next force_cast
               XCTAssertEqual(error as! NetworkAPI.Error, NetworkAPI.Error.codingError("Request JSON encoding failed, probably due to an invalid value"))
        }
    }

    func testPOSTEncodesString() {
        struct TestRequest: Request {
            typealias Parameters = [String: String]
            typealias Returning = Empty

            public var method: HTTPMethod { return .post }
            public var path: String {
                return "test"
            }

            public var parameters: [String: String] {
                return ["test": "🤞"]
            }
        }
        var urlRequest = URLRequest(url: URL(string: "https://www.steamclock.com")!)

        try? urlRequest.encodeParameters(for: TestRequest())
        guard let body = urlRequest.httpBody else {
                XCTFail("POST Request parameter encoding failed to encode HTTPBody")
                return
        }

        XCTAssert(String(data: body, encoding: String.Encoding.utf8) == "{\"test\":\"🤞\"}")
    }

    func testPOSTEncodesInt() {
        struct TestRequest: Request {
            typealias Parameters = [String: Int]
            typealias Returning = Empty

            public var method: HTTPMethod { return .post }
            public var path: String {
                return "test"
            }

            public var parameters: [String: Int] {
                return ["test": 1]
            }
        }
        var urlRequest = URLRequest(url: URL(string: "https://www.steamclock.com")!)

        try? urlRequest.encodeParameters(for: TestRequest())
        guard let body = urlRequest.httpBody else {
            XCTFail("POST Request parameter encoding failed to encode HTTPBody")
            return
        }

        XCTAssert(String(data: body, encoding: String.Encoding.utf8) == "{\"test\":1}")
    }

    // MARK: - Server Response Tests

    func testRequestCommonErrorCodesReturnHTTPError() {
        struct TestGETRequest: Request {
            typealias Parameters = Empty
            typealias Returning = Empty

            public var method: HTTPMethod { return .get }
            public var path: String

            init(path: String) {
                self.path = path
            }
        }

        let expect401 = XCTestExpectation(description: "401 error caught")
        stub(uri("/401"), http(401))
        api.request(TestGETRequest(path: "401")) { result in
            switch result {
            case .success:
                XCTFail("GET request didn't catch 401")
            case .failure(let error):
                if error == NetworkAPI.Error.httpError(401) {
                    expect401.fulfill()
                }
            }
        }

        let expect404 = XCTestExpectation(description: "404 error caught")
        stub(uri("/404"), http(404))
        api.request(TestGETRequest(path: "404")) { result in
            switch result {
            case .success:
                XCTFail("GET request didn't catch 404")
            case .failure(let error):
                if error == NetworkAPI.Error.httpError(404) {
                    expect404.fulfill()
                }
            }
        }

        let expect500 = XCTestExpectation(description: "500 error caught")
        stub(uri("/500"), http(500))
        api.request(TestGETRequest(path: "500")) { result in
            switch result {
            case .success:
                XCTFail("GET request didn't catch 500")
            case .failure(let error):
                if error == NetworkAPI.Error.httpError(500) {
                    expect500.fulfill()
                }
            }
        }

        wait(for: [expect401, expect404, expect500], timeout: 10.0)
    }
}
