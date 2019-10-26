//
//  BitlyApiTests.swift
//  BitlyTests
//
//  Created by Roberto Mauro on 21/10/2019.
//  Copyright © 2019 Roberto Mauro. All rights reserved.
//

import XCTest
@testable import Bitly

class BitlyApiTests: XCTestCase {
    
    var API_KEY: String = ""

    override func setUp() {
        API_KEY = ProcessInfo.processInfo.environment["BITLY_API_KEY"] ?? ""
        
        // Run Environment variable BITLY_API_KEY should be set
        XCTAssertNotEqual(API_KEY, "")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testInitWithKey() {
        let mockUserDefaultsContainer = MockUserDefaultsContainer()
        mockUserDefaultsContainer.apiKey = API_KEY
        
        let mockUserDefaultsService = UserDefaultsService(settings: mockUserDefaultsContainer)
        let api = BitlyApi(userDefaults: mockUserDefaultsService)
        
        XCTAssertTrue(api.apiKey == API_KEY)
    }
    
    func testSuccessfulShortening() {
        let mockUserDefaultsContainer = MockUserDefaultsContainer()
        mockUserDefaultsContainer.apiKey = API_KEY
        
        let mockUserDefaultsService = UserDefaultsService(settings: mockUserDefaultsContainer)
        let api = BitlyApi(userDefaults: mockUserDefaultsService)
        
        let testLongURL = "http://www.google.com"
        let expectation = self.expectation(description: "shorten")
        var shortLinkResult: BitlyShortLink = BitlyShortLink(longUrl: "none", link: "none")
        
        api.shorten(url: testLongURL) { result in
            switch result {
                case .success(let shortLink):
                    shortLinkResult = shortLink
                    expectation.fulfill()
                    break
                case .failure:
                    expectation.fulfill()
                    break
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertNotEqual(shortLinkResult.link, "none")
    }
    
    func testFailureWithoutKey() {
        let mockUserDefaultsContainer = MockUserDefaultsContainer()
        mockUserDefaultsContainer.apiKey = "no-key"
        
        let mockUserDefaultsService = UserDefaultsService(settings: mockUserDefaultsContainer)
        let api = BitlyApi(userDefaults: mockUserDefaultsService)
        
        
        let testLongURL = "http://www.google.com"
        let expectation = self.expectation(description: "shorten")
        var errorResult: BitlyApiError = .noData
        
        api.shorten(url: testLongURL) { result in
            switch result {
                case .success:
                    expectation.fulfill()
                    break
                case .failure(let error):
                    errorResult = error
                    expectation.fulfill()
                    break
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertNotNil(errorResult)
        XCTAssertEqual(errorResult, .forbidden)
    }
    
    func testFailureWithInvalidUrl() {
        let mockUserDefaultsContainer = MockUserDefaultsContainer()
        mockUserDefaultsContainer.apiKey = API_KEY
        
        let mockUserDefaultsService = UserDefaultsService(settings: mockUserDefaultsContainer)
        let api = BitlyApi(userDefaults: mockUserDefaultsService)
        
        let invalidLongURL = "foobar"
        let expectation = self.expectation(description: "invalid long url format")
        var errorResult: BitlyApiError = .noData
        
        api.shorten(url: invalidLongURL) { result in
            switch result {
                case .success:
                    expectation.fulfill()
                    break
                case .failure(let error):
                    errorResult = error
                    expectation.fulfill()
                    break
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertNotNil(errorResult)
        XCTAssertEqual(errorResult, .invalidArgument)
    }
    
    func testUpdateOnApiKeyChangeNotification() {
        let mockUserDefaultsContainer = MockUserDefaultsContainer()
        mockUserDefaultsContainer.apiKey = API_KEY
        
        let mockUserDefaultsService = UserDefaultsService(settings: mockUserDefaultsContainer)
        let api = BitlyApi(userDefaults: mockUserDefaultsService)
        
        // post notification of changes
        let newApiKey = "foobar"
        
        NotificationCenter.default.post(name: .apiKeyChanged, object: nil, userInfo: ["apiKey": newApiKey])
        
        XCTAssertEqual(api.apiKey, newApiKey)
    }
}

// MARK: Mocks

class MockUserDefaultsContainer: ISettings {
    var apiKey: String = ""
    var hideIcon: Bool = false
}
