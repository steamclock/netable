//
//  SCNetworkAPIMobileTests.swift
//  SCNetworkAPIMobileTests
//
//  Created by Brendan Lensink on 2018-10-19.
//

import Mockingjay
@testable import SCNetworkAPI
import XCTest

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

    // MARK: fullyQualifiedURLFrom(path: String) Tests

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
}
