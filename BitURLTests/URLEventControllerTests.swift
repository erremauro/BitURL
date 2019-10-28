//
//  URLEventControllerTests.swift
//  BitURLTests
//
//  Created by Roberto Mauro on 26/10/2019.
//  Copyright © 2019 Roberto Mauro. All rights reserved.
//

import XCTest
@testable import BitURL

class URLEventControllerTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPerformShortenAction() {
        let apiServiceExpectation = self.expectation(description: "apiServiceExpectation")
        let notificationCenterExpectation = self.expectation(description: "notificationCenterExpectation")
        
        let longURL = "http://www.google.com"
        let actionName = "shorten"
        let actionSchemaURL = "biturl://\(actionName)/\(longURL)"
        let expectedShortURL = "https://bit.ly/test"
        
        let notificationCenter = MockNotificationCenter()
        let pasteboardService = MockPasteboardService()
        
        // should post notification
        notificationCenter.onAction = { message in
            XCTAssertNotNil(message)
            XCTAssertEqual(pasteboardService.stringValue, expectedShortURL)

            notificationCenterExpectation.fulfill()
            
        }
        
        let notificationService: INotificationService = NotificationService(using: notificationCenter)
        let apiService = MockBitlyApi()
        
        // should call api for URL shortening
        apiService.onRequest = { action, shortURL in
            XCTAssertEqual(action, .shorten)
            XCTAssertEqual(shortURL.link, expectedShortURL)
            
            apiServiceExpectation.fulfill()
        }
        
        let notificationController = URLEventController(using: apiService, notificationService: notificationService, pasteboardService: pasteboardService)
        notificationController.performAction(for: actionSchemaURL)
        
        wait(for: [apiServiceExpectation, notificationCenterExpectation], timeout: 10)
    }
}

// MARK: Mocks

class MockBitlyApi: IBitlyApi {
    func isAuthorized(result: @escaping (Result<Bool, BitlyApiError>) -> Void) {
        let authorized = true
        result(.success(authorized))
    }
    
    func user(result: @escaping (Result<BitlyUser, BitlyApiError>) -> Void) {
        let bitlyUser = BitlyUser(name: "No Name", isActive: false, login: "No Login")
        result(.success(bitlyUser))
    }
    
    var apiKey: String = ""
    
    var onRequest: (_: URLEventActionName, _:BitlyShortLink) -> Void = { action, shortURL in
        print("[\(String(describing: action))] \(shortURL.link)")
    }
    
    func shorten(url: String, result: @escaping (Result<BitlyShortLink, BitlyApiError>) -> Void) {
        let shortURL = BitlyShortLink(longUrl: url, link: "https://bit.ly/test")
        result(.success(shortURL))
        onRequest(.shorten, shortURL)
    }
}

class MockPasteboardService: IPasteboardService {
    var stringValue: String = ""
    
    func setString(_ stringValue: String) {
        self.stringValue = stringValue
    }
}
