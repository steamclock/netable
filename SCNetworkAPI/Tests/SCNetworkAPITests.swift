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
        let (url, error) = api.fullyQualifiedURLFrom(path: baseURL)
        XCTAssert(error == nil)
        XCTAssert(url?.absoluteString == baseURL)
    }

    func testPartialURLToFullyQualifiedWithSlash() {
        let path = "/test"
        let (url, error) = api.fullyQualifiedURLFrom(path: path)
        XCTAssert(error == nil)
        XCTAssert(url?.absoluteString == baseURL + "/test")
    }

    func testPartialURLToFullyQualifiedNoSlash() {
        let path = "test"
        let (url, error) = api.fullyQualifiedURLFrom(path: path)
        XCTAssert(error == nil)
        XCTAssert(url?.absoluteString == baseURL + "/test")
    }

    func testInvalidURLDelimReturnsError() {
        let (url, error) = api.fullyQualifiedURLFrom(path: "<")
        XCTAssert(url == nil)
        XCTAssert(error != nil)
    }

    func testInvalidURLControlCharacterReturnsError() {
        let (url, error) = api.fullyQualifiedURLFrom(path: "\(UnicodeScalar(00)!)")
        XCTAssert(url == nil)
        XCTAssert(error != nil)
    }

    func testInvalidURLSpaceReturnsError() {
        let (url, error) = api.fullyQualifiedURLFrom(path: "\(UnicodeScalar(20)!)")
        XCTAssert(url == nil)
        XCTAssert(error != nil)
    }

    func testFullURLBaseDoesntMatchErrors() {
        let (url, error) = api.fullyQualifiedURLFrom(path: "https://www.google.com")
        XCTAssert(url == nil)
        XCTAssert(error != nil)
    }
}
