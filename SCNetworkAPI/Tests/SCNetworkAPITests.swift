//
//  SCNetworkAPIMobileTests.swift
//  SCNetworkAPIMobileTests
//
//  Created by Brendan Lensink on 2018-10-19.
//

import Mockingjay
import enum SCNetworkAPI.NetworkAPIError
import enum SCNetworkAPI.HTTPMethod
@testable import SCNetworkAPI
import XCTest

extension NetworkAPIError: Equatable {
    public static func == (lhs: NetworkAPIError, rhs: NetworkAPIError) -> Bool {
        switch (lhs, rhs) {
        case (.codingError, .codingError): return true
        case (.httpError(let lhsCode), .httpError(let rhsCode)): return lhsCode == rhsCode
        case (.malformedURL, .malformedURL): return true
        // Note that .requestFailed doesn't check the underlying error
        case (.requestFailed, .requestFailed): return true
        case (.wrongServer, .wrongServer): return true
        case (.noData, .noData): return true
        default: return false
        }
    }
}

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
            XCTAssertEqual(error as! NetworkAPIError, NetworkAPIError.malformedURL)
        }
    }

    func testInvalidURLControlCharacterReturnsError() {
        XCTAssertThrowsError(try api.fullyQualifiedURLFrom(path: "\(UnicodeScalar(00)!)")) { error in
            //swiftlint:disable:next force_cast
            XCTAssertEqual(error as! NetworkAPIError, NetworkAPIError.malformedURL)
        }
    }

    func testInvalidURLSpaceReturnsError() {
        XCTAssertThrowsError(try api.fullyQualifiedURLFrom(path: "\(UnicodeScalar(20)!)")) { error in
            //swiftlint:disable:next force_cast
            XCTAssertEqual(error as! NetworkAPIError, NetworkAPIError.malformedURL)
        }
    }

    func testFullURLBaseDoesntMatchErrors() {
        XCTAssertThrowsError(try api.fullyQualifiedURLFrom(path: "https://www.google.com")) { error in
            //swiftlint:disable:next force_cast
            XCTAssertEqual(error as! NetworkAPIError, NetworkAPIError.wrongServer)
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
        } catch let error as NetworkAPIError {
            XCTAssert(error == NetworkAPIError.codingError(""))
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
        } catch let error as NetworkAPIError {
            XCTAssert(error == NetworkAPIError.codingError(""))
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
        } catch let error as NetworkAPIError {
            XCTAssert(error == NetworkAPIError.codingError(""))
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
        print(url)
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
            //swiftlint:disable:next force_cast
               XCTAssertEqual(error as! NetworkAPIError, NetworkAPIError.codingError("Request JSON encoding failed, probably due to an invalid value"))
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

    func testRequestCommonErrorCodesReturnHTTPError() {
        struct TestGETRequest: Request {
            typealias Parameters = Empty
            typealias RawResource = Empty

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
                if error == NetworkAPIError.httpError(401, Data()) {
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
                if error == NetworkAPIError.httpError(404, Data()) {
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
                if error == NetworkAPIError.httpError(500, Data()) {
                    expect500.fulfill()
                }
            }
        }

        wait(for: [expect401, expect404, expect500], timeout: 10.0)
    }
}
