//
//  BitlyApiTests.swift
//  BitURLTests
//
//  Created by Roberto Mauro on 21/10/2019.
//  Copyright © 2019 Roberto Mauro. All rights reserved.
//

import XCTest
@testable import BitURL

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

        api.shorten(url: testLongURL) { result in
            switch result {
                case .success(let shortLink):
                    XCTAssertNotEqual(shortLink.link, "none")
                    expectation.fulfill()
                    break
                case .failure:
                    break
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testFailureWithoutKey() {
        let mockUserDefaultsContainer = MockUserDefaultsContainer()
        mockUserDefaultsContainer.apiKey = "no-key"
        
        let mockUserDefaultsService = UserDefaultsService(settings: mockUserDefaultsContainer)
        let api = BitlyApi(userDefaults: mockUserDefaultsService)
            
        let testLongURL = "http://www.google.com"
        let expectation = self.expectation(description: "shorten")
        
        api.shorten(url: testLongURL) { result in
            switch result {
                case .success:
                    break
                case .failure(let error):
                    XCTAssertNotNil(error)
                    XCTAssertEqual(error, .forbidden)
                    expectation.fulfill()
                    break
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
        
    }
    
    func testFailureWithInvalidUrl() {
        let mockUserDefaultsContainer = MockUserDefaultsContainer()
        mockUserDefaultsContainer.apiKey = API_KEY
        
        let mockUserDefaultsService = UserDefaultsService(settings: mockUserDefaultsContainer)
        let api = BitlyApi(userDefaults: mockUserDefaultsService)
        
        let invalidLongURL = "foobar"
        let expectation = self.expectation(description: "invalid long url format")
        
        api.shorten(url: invalidLongURL) { result in
            switch result {
                case .success:
                    break
                case .failure(let error):
                    XCTAssertNotNil(error)
                    XCTAssertEqual(error, .invalidArgument)
                    expectation.fulfill()
                    break
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
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
    
    func testUserShouldNotBeFound() {
        let expectation = self.expectation(description: "userNotFound")
        
        let mockUserDefaultsContainer = MockUserDefaultsContainer()
        let mockUserDefaultsService = UserDefaultsService(settings: mockUserDefaultsContainer)
        let api = BitlyApi(userDefaults: mockUserDefaultsService)
        
        api.user() { result in
            switch result {
                case .success(_):
                    break
                case .failure(let error):
                    XCTAssertNotNil(error)
                    expectation.fulfill()
                    break
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
        
    }
    
    func testUserShouldBeFound() {
        let expectation = self.expectation(description: "userFound")
        let mockUserDefaultsContainer = MockUserDefaultsContainer()
        mockUserDefaultsContainer.apiKey = API_KEY
        
        let mockUserDefaultsService = UserDefaultsService(settings: mockUserDefaultsContainer)
        let api = BitlyApi(userDefaults: mockUserDefaultsService)
        
        api.user() { result in
            switch result {
                case .success(let bitlyUser):
                    XCTAssertNotNil(bitlyUser)
                    expectation.fulfill()
                    break
                case .failure(let error):
                    XCTAssertNil(error)
                    expectation.fulfill()
                    break
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testIsAuthorized() {
        let expectation = self.expectation(description: "shouldBeAuthenticated")
        let mockUserDefaultsContainer = MockUserDefaultsContainer()
        mockUserDefaultsContainer.apiKey = API_KEY
        
        let mockUserDefaultsService = UserDefaultsService(settings: mockUserDefaultsContainer)
        let api = BitlyApi(userDefaults: mockUserDefaultsService)
        
        api.isAuthorized() { result in
            switch result {
            case .success(let isAuthorized):
                XCTAssertTrue(isAuthorized)
                expectation.fulfill()
                break
            case .failure(_):
                break
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testIsNotAuthorized() {
        let expectation = self.expectation(description: "shouldBeAuthenticated")
        let mockUserDefaultsContainer = MockUserDefaultsContainer()
        mockUserDefaultsContainer.apiKey = "invalid-api-key"
        
        let mockUserDefaultsService = UserDefaultsService(settings: mockUserDefaultsContainer)
        let api = BitlyApi(userDefaults: mockUserDefaultsService)
        
        api.isAuthorized() { result in
            switch result {
            case .success(let isAuthorized):
                XCTAssertFalse(isAuthorized)
                expectation.fulfill()
                break
            case .failure(_):
                break
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testShouldReverseValidBitlyLink() {
        let expectation = self.expectation(description: "shouldBeAuthenticated")
        let mockUserDefaultsContainer = MockUserDefaultsContainer()
        mockUserDefaultsContainer.apiKey = API_KEY
        
        let mockUserDefaultsService = UserDefaultsService(settings: mockUserDefaultsContainer)
        let api = BitlyApi(userDefaults: mockUserDefaultsService)
        let bitlyURL = "http://bit.ly/32uy8JB"
        let expectedURL = "http://www.google.com/"
        
        api.reverse(url: bitlyURL) { result in
            switch result {
            case .success(let shortURL):
                XCTAssertEqual(expectedURL, shortURL.longUrl)
                expectation.fulfill()
                break
            case .failure(let error):
                XCTAssertNil(error)
                expectation.fulfill()
                break
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testShouldReverseBitlyLinkWithoutProtocol() {
        let expectation = self.expectation(description: "shouldBeAuthenticated")
        let mockUserDefaultsContainer = MockUserDefaultsContainer()
        mockUserDefaultsContainer.apiKey = API_KEY
        
        let mockUserDefaultsService = UserDefaultsService(settings: mockUserDefaultsContainer)
        let api = BitlyApi(userDefaults: mockUserDefaultsService)
        let bitlyURL = "bit.ly/32uy8JB"
        let expectedURL = "http://www.google.com/"
        
        api.reverse(url: bitlyURL) { result in
            switch result {
            case .success(let shortURL):
                XCTAssertEqual(expectedURL, shortURL.longUrl)
                expectation.fulfill()
                break
            case .failure(let error):
                XCTAssertNil(error)
                expectation.fulfill()
                break
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testShouldFailOnInvalidURLs() {
        let expectation = self.expectation(description: "shouldBeAuthenticated")
        let mockUserDefaultsContainer = MockUserDefaultsContainer()
        mockUserDefaultsContainer.apiKey = API_KEY
        
        let mockUserDefaultsService = UserDefaultsService(settings: mockUserDefaultsContainer)
        let api = BitlyApi(userDefaults: mockUserDefaultsService)
        let bitlyURL = "not-a-url"
        
        api.reverse(url: bitlyURL) { result in
            switch result {
            case .success(_):
                break
            case .failure(let error):
                XCTAssertEqual(error, .encodeError)
                expectation.fulfill()
                break
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
}

// MARK: Mocks

class MockUserDefaultsContainer: ISettings {
    var apiKey: String = ""
    var hideIcon: Bool = false
    var hideNotifications: Bool = false
}
