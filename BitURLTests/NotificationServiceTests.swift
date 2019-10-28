//
//  NotificationServiceTests.swift
//  BitURLTests
//
//  Created by Roberto Mauro on 26/10/2019.
//  Copyright © 2019 Roberto Mauro. All rights reserved.
//

import XCTest
@testable import BitURL

class NotificationServiceTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSuccessNotification() {
        let expectation = self.expectation(description: "successNotification")
        let mockNotificationCenter = MockNotificationCenter()
        let expectedNotificationString = "[Optional(\"Bitly\")] Optional(\"Test Title\"): Optional(\"Test Message\")"
        
        mockNotificationCenter.onAction = { message in
            XCTAssertEqual(expectedNotificationString, message)
            
            expectation.fulfill()
        }
        let notificationService = NotificationService(using: mockNotificationCenter)
        notificationService.notifySuccess(title: "Test Title", message: "Test Message")
        
        waitForExpectations(timeout: 10, handler: nil)

    }
    
    func testFailureNotification() {
        let expectation = self.expectation(description: "failureNotification")
        let mockNotificationCenter = MockNotificationCenter()
        let expectedNotificationString = "[Optional(\"Bitly\")] Optional(\"Test Title\"): Optional(\"Test Message\")"
        
        mockNotificationCenter.onAction = { message in
            XCTAssertEqual(expectedNotificationString, message)
            
            expectation.fulfill()
        }
        let notificationService = NotificationService(using: mockNotificationCenter)
        notificationService.notifyFailure(title: "Test Title", message: "Test Message")
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testAddObserver() {
        let expectation = self.expectation(description: "failureNotification")
        let expectedNotificationString = "[addObserver] testNotification action added"
        let testNotificationName = Notification.Name("testNotification")
        let mockNotificationCenter = MockNotificationCenter()
        
        mockNotificationCenter.onAction = { message in
            XCTAssertEqual(expectedNotificationString, message)
            
            expectation.fulfill()
        }
        
        mockNotificationCenter.addObserver(self, selector: #selector(mockSelectorFunc(_:)), name: testNotificationName)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func mockSelectorFunc(_: String) {
        
    }

}

// MARK: Mocks

class MockNotificationCenter: IUserNotificationCenter {
    static var shared: IUserNotificationCenter = MockNotificationCenter()
    
    init() {}
        
    var onAction: (_: String) -> Void = { message in
        print(message)
    }
    
    func deliver(_ notification: NSUserNotification) {
        onAction(formatNotification(notification))
    }
    
    func addObserver(_ observer: Any, selector: Selector, name: Notification.Name) {
        onAction("[addObserver] \(name.rawValue) action added")
    }
    
    func post(name: Notification.Name, userInfo: [AnyHashable : Any]?) {
        onAction("[post] \(name.rawValue): \(String(describing: userInfo)) ")
    }
    
    func formatNotification(_ notification: NSUserNotification) -> String {
        let notificationTitle = String(describing: notification.title)
        let notificationSubtitle = String(describing: notification.subtitle)
        let notificationMessage = String(describing: notification.informativeText)
        
        return "[\(notificationTitle)] \(notificationSubtitle): \(notificationMessage)"
    }
}
