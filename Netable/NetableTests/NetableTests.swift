//
//  NetableTests.swift
//  NetableTests
//
//  Created by Jeremy Chiang on 2020-02-04.
//  Copyright © 2020 Steamclock Software. All rights reserved.
//

import XCTest
@testable import Netable
@testable import OHHTTPStubs
@testable import OHHTTPStubsSwift

class NetableTests: XCTestCase {
    let testTimeout: TimeInterval = 15
    let baseURL = "https://www.steamclock.com"
    var netable: Netable!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        netable = Netable(baseURL: URL(string: baseURL)!)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        HTTPStubs.removeAllStubs()
    }

    // MARK: - fullyQualifiedURLFrom(path: String) Tests
    func testFullyQualifiedURLIsUnchanged() {
        let url = try? netable.fullyQualifiedURLFrom(path: baseURL)
        XCTAssert(url?.absoluteString == baseURL)
    }

    func testPartialURLToFullyQualifiedWithSlash() {
        let path = "/test"
        let url = try? netable.fullyQualifiedURLFrom(path: path)
        XCTAssert(url?.absoluteString == baseURL + "/test")
    }

    func testPartialURLToFullyQualifiedNoSlash() {
        let path = "test"
        let url = try? netable.fullyQualifiedURLFrom(path: path)
        XCTAssert(url?.absoluteString == baseURL + "/test")
    }

    func testInvalidURLDelimReturnsError() {
        XCTAssertThrowsError(try netable.fullyQualifiedURLFrom(path: "<")) { error in
            XCTAssertEqual(error as! NetableError, NetableError.malformedURL)
        }
    }

    func testInvalidURLControlCharacterReturnsError() {
        XCTAssertThrowsError(try netable.fullyQualifiedURLFrom(path: "\(UnicodeScalar(00)!)")) { error in
            XCTAssertEqual(error as! NetableError, NetableError.malformedURL)
        }
    }

    func testInvalidURLSpaceReturnsError() {
        XCTAssertThrowsError(try netable.fullyQualifiedURLFrom(path: "\(UnicodeScalar(20)!)")) { error in
            XCTAssertEqual(error as! NetableError, NetableError.malformedURL)
        }
    }

    func testFullURLBaseDoesntMatchErrors() {
        XCTAssertThrowsError(try netable.fullyQualifiedURLFrom(path: "https://www.google.com")) { error in
            XCTAssertEqual(error as! NetableError, NetableError.wrongServer)
        }
    }

    // MARK: - Parameter Encoding Tests
    func testGETCatchesArrayParameters() {
        struct TestGETRequest: Request {
            typealias Parameters = [String]
            typealias RawResource = Empty

            public var method: HTTPMethod { return .get }
            public var path: String {
                return "test"
            }

            public var parameters: [String] {
                return ["test"]
            }
        }

        var urlRequest = URLRequest(url: URL(string: "https://www.steamclock.com")!)
        do {
            try urlRequest.encodeParameters(for: TestGETRequest())
            XCTFail("Array parameters passed")
        } catch let error as NetableError {
            XCTAssert(error == NetableError.codingError("Encoding Error: Failed to create url parameters: codingError(\"Coding error: Failed to unwrap parameter dictionary\")"))
        } catch {
            XCTFail("Failed to throw correct coding error")
        }
    }

    func testGETCatchesNestedDict() {
        struct TestGETRequest: Request {
            typealias Parameters = [String: [String]]
            typealias RawResource = Empty

            public var method: HTTPMethod { return .get }
            public var path: String {
                return "test"
            }

            public var parameters: [String: [String]] {
                return ["test": ["test"]]
            }
        }

        var urlRequest = URLRequest(url: URL(string: "https://www.steamclock.com")!)
        do {
            try urlRequest.encodeParameters(for: TestGETRequest())
            XCTFail("Nested dict parameters passed")
        } catch let error as NetableError {
            XCTAssert(error == NetableError.codingError("Encoding Error: Failed to create url parameters: codingError(\"Coding error: Cannot encode nested collections\")"))
        } catch {
            XCTFail("Failed to throw correct coding error")
        }
    }

    func testGETCatchesSingleValueEncodedParameters() {
        struct SVEC: Codable {
            let string: String

            init(_ string: String) {
                self.string = string
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                let string = try container.decode(String.self)
                self.init(string)
            }

            public func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encode(string)
            }
        }

        struct TestGETRequest: Request {
            typealias Parameters = SVEC
            typealias RawResource = Empty

            public var method: HTTPMethod { return .get }
            public var path: String {
                return "test"
            }

            public var parameters: SVEC {
                return SVEC("test")
            }
        }

        var urlRequest = URLRequest(url: URL(string: "https://www.steamclock.com")!)
        do {
            try urlRequest.encodeParameters(for: TestGETRequest())
            XCTFail("SVEC parameters passed")
        } catch let error as NetableError {
            XCTAssert(error == NetableError.codingError("Encoding Error: Failed to create url parameters: codingError(\"Coding error: Failed to unwrap parameter dictionary\")"))
        } catch {
            XCTFail("Failed to throw correct coding error")
        }
    }

    func testGETCatchesEmptyParameters() {
        struct TestGETRequest: Request {
            typealias Parameters = [String: String]
            typealias RawResource = Empty

            public var method: HTTPMethod { return .get }
            public var path: String {
                return "test"
            }

            public var parameters: [String: String] {
                return [:]
            }
        }

        var urlRequest = URLRequest(url: URL(string: "https://www.steamclock.com")!)
        try? urlRequest.encodeParameters(for: TestGETRequest())

        guard let url = urlRequest.url else {
            XCTFail("Failed to unwrap url from GET request")
            return
        }

        XCTAssert(url.absoluteString == "https://www.steamclock.com?")
    }

    func testGETEncodesEscapedCharacters() {
        struct TestGETRequest: Request {
            typealias Parameters = [String: String]
            typealias RawResource = Empty

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

    func testGETRequestString() {
        struct TestGETRequest: Request {
            typealias Parameters = [String: String]
            typealias RawResource = Empty

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

    func testGETRequestInt() {
        struct TestGETRequest: Request {
            typealias Parameters = [String: Int]
            typealias RawResource = Empty

            public var method: HTTPMethod { return .get }
            public var path: String {
                return "test"
            }

            public var parameters: [String: Int] {
                return ["type": 2]
            }
        }

        var urlRequest = URLRequest(url: URL(string: "https://www.steamclock.com")!)
        try? urlRequest.encodeParameters(for: TestGETRequest())

        guard let url = urlRequest.url else {
            XCTFail("Failed to unwrap url from GET request")
            return
        }

        XCTAssert(url.absoluteString == "https://www.steamclock.com?type=2")
    }

    func testGETRequestCodableParams() {
        struct MyParams: Codable {
            var a: String
            var b: Int
        }

        struct TestGETRequest: Request {
            typealias Parameters = MyParams
            typealias RawResource = Empty

            public var method: HTTPMethod { return .get }
            public var path: String {
                return "test"
            }

            public var parameters: MyParams {
                return MyParams(a: "foo", b: 2)
            }
        }

        var urlRequest = URLRequest(url: URL(string: "https://www.steamclock.com")!)
        try? urlRequest.encodeParameters(for: TestGETRequest())

        guard let url = urlRequest.url else {
            XCTFail("Failed to unwrap url from GET request")
            return
        }

        print(url.absoluteString)
        XCTAssert(
            url.absoluteString == "https://www.steamclock.com?a=foo&b=2" ||
            url.absoluteString == "https://www.steamclock.com?b=2&a=foo"
        )
    }

    func testPOSTContentTypeIsJSON() {
        struct TestPOSTRequest: Request {
            typealias Parameters = [String: String]
            typealias RawResource = Empty

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
            typealias RawResource = Empty

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
            XCTAssertEqual(error as! NetableError, NetableError.codingError("Encoding Error: Failed to create request body: Coding error: The data couldn’t be written because it isn’t in the correct format."))
        }
    }

    func testPOSTEncodesString() {
        struct TestRequest: Request {
            typealias Parameters = [String: String]
            typealias RawResource = Empty

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
            typealias RawResource = Empty

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
    struct TestGETRequest: Request {
        typealias Parameters = Empty
        typealias RawResource = Empty

        public var method: HTTPMethod { return .get }
        public var path: String

        init(path: String) {
            self.path = path
        }
    }

    func test401() {
        stub(condition: isMethodGET()) { _ -> HTTPStubsResponse in
            return HTTPStubsResponse(data: Data(), statusCode: 401, headers: nil)
        }

        let expect401 = expectation(description: "401 error caught")

        netable.request(TestGETRequest(path: "401")) { result in
            switch result {
            case .success:
                XCTFail("GET request didn't catch 401")
            case .failure(let error):
                if error == NetableError.httpError(401, Data()) {
                    expect401.fulfill()
                } else {
                    XCTFail("GET request didn't catch 401")
                }
            }
        }

        waitForExpectations(timeout: testTimeout)
    }

    func test404() {
        stub(condition: isMethodGET()) { _ -> HTTPStubsResponse in
            return HTTPStubsResponse(data: Data(), statusCode: 404, headers: nil)
        }

        let expect404 = expectation(description: "404 error caught")

        netable.request(TestGETRequest(path: "404")) { result in
            switch result {
            case .success:
                XCTFail("GET request didn't catch 404")
            case .failure(let error):
                if error == NetableError.httpError(404, Data()) {
                    expect404.fulfill()
                } else {
                    XCTFail("GET request didn't catch 404")
                }
            }
        }

        waitForExpectations(timeout: testTimeout)
    }

    func test500() {
        stub(condition: isMethodGET()) { _ -> HTTPStubsResponse in
            return HTTPStubsResponse(data: Data(), statusCode: 500, headers: nil)
        }

        let expect500 = expectation(description: "500 error caught")

        netable.request(TestGETRequest(path: "500")) { result in
            switch result {
            case .success:
                XCTFail("GET request didn't catch 500")
            case .failure(let error):
                if error == NetableError.httpError(500, Data()) {
                    expect500.fulfill()
                } else {
                    XCTFail("GET request didn't catch 500")
                }
            }
        }

        waitForExpectations(timeout: testTimeout)
    }
}
