//
//  FetchServicesTests.swift
//  BitURLTests
//
//  Created by Roberto Mauro on 28/10/2019.
//  Copyright © 2019 Roberto Mauro. All rights reserved.
//

import XCTest
@testable import BitURL

class FetchServicesTests: XCTestCase {
    var API_KEY = ""
    var ENDPOINT = "https://api-ssl.bitly.com/v4"

    override func setUp() {
        API_KEY = ProcessInfo.processInfo.environment["BITLY_API_KEY"] ?? ""
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testShouldFetchSuccessfully() {
        let expectation = self.expectation(description: "shouldFetchSuccessfully")
        let fetchService = FetchService()
        let options = FetchOptions(
            url: ENDPOINT + "/user",
            method: .get,
            headers: [
                "Authorization": "Bearer " + API_KEY
            ]
        )
        
        fetchService.fetch(options: options) { result in
            switch result {
            case .success((let status,let response)):
                XCTAssertEqual(status.statusCode, 200)
                XCTAssertNotNil(response)
                print("response: \(response)")
                expectation.fulfill()
                break
            case .failure(_):
                break
            }
        }

        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testShouldReturnResponseFor400s() {
        let expectation = self.expectation(description: "shouldFetchSuccessfully")
        let fetchService = FetchService()
        let options = FetchOptions(
            url: ENDPOINT + "/user",
            method: .get,
            headers: [
                "Authorization": "Bearer " // no api key should return a 403 response
            ]
        )
        
        fetchService.fetch(options: options) { result in
            switch result {
            case .success(let status, let response):
                XCTAssertEqual(status.statusCode, 403)
                XCTAssertNotNil(response)
                expectation.fulfill()
                break
            case .failure(_):
                break
            }
        }

        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testShouldThrowInvalidUrlFormat() {
        let expectation = self.expectation(description: "shouldThrowInvalidUrlFormat")
        let invalidURL = "https:\\invalid-url.com"
        let fetchService = FetchService()
        let options = FetchOptions(
            url: invalidURL,
            method: .get
        )
        
        fetchService.fetch(options: options) { result in
            switch result {
            case .success(_):
                break
            case .failure(let error):
                XCTAssertEqual(error, .invalidUrlFormat)
                expectation.fulfill()
                break
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
}
