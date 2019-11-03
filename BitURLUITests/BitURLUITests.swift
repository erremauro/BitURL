//
//  BitlyUITests.swift
//  BitURLUITests
//
//  Created by Roberto Mauro on 20/10/2019.
//  Copyright © 2019 Roberto Mauro. All rights reserved.
//

import XCTest

class BitURLUITests: XCTestCase {
    var API_KEY: String = ""
    
    func getApp(apiKey: String? = nil, hideIcon: Bool = true, hideNotifications: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments.append(contentsOf: ["-apiKey", apiKey ?? API_KEY])
        app.launchArguments.append(contentsOf: ["-hideIcon", hideIcon ? "YES" : "NO"])
        app.launchArguments.append(contentsOf: ["-hideNotifications", hideNotifications ? "YES" : "NO"])
        return app
    }
    
    override func setUp() {

        // Get the test API_KEY from the environment variables
        API_KEY = ProcessInfo.processInfo.environment["BITLY_API_KEY"] ?? ""
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
    }
    
    func testFirstRunConfiguration() {
        var app = getApp(apiKey: "", hideIcon: false)
        app.launch()
        
        // Main Window UI Elements
        var mainWindow: XCUIElement { return app.windows["MainWindowId"] }
        var apiTokenField: XCUIElement { return mainWindow.textFields["MainApiTokenFieldId"] }
        var hideIconCheckbox: XCUIElement { return mainWindow.checkBoxes["MainHideIconCheckboxId"] }
        var configureButton: XCUIElement { return mainWindow.buttons["MainConfigureButtonId"] }
        var statusIcon: XCUIElement { return mainWindow.images["MainStatusIconId"] }
        
        // Check that the configuration button is disabled and no status icon is visible
        XCTAssertFalse(configureButton.isEnabled)
        XCTAssertFalse(statusIcon.exists)
        
        // fill in the api key in the api token field and press enter to confirm
        apiTokenField.click()
        apiTokenField.typeText(API_KEY)
        apiTokenField.typeText(XCUIKeyboardKey.enter.rawValue)
        
        // activate hide icon checkbox
        hideIconCheckbox.click()
        
        // wait for api check rest response to be received
        sleep(2)
        
        // check that the configuration button is enabled and the status icon visible
        XCTAssertTrue(configureButton.isEnabled)
        XCTAssertTrue(statusIcon.isHittable)
        
        // click the configuration button to confirm
        configureButton.click()
        
        // check that the main window is now closed
        XCTAssertFalse(mainWindow.exists)
        
        app.terminate()
        
        // Reopen the application to check that the modifications are persisting.
        // This thime we'll use `XCXUIApplication` because we don't want to force
        // any initial argument like done by the `getApp` function
        app = XCUIApplication()
        app.launch()
        
        // Preferences UI Elements
        var statusBarMenu: XCUIElement {
            return app.children(matching: .menuBar).element(boundBy: 1).children(matching: .statusItem).element
        }
        var preferencesMenu: XCUIElement { return app.menuBars.menuItems["PreferencesMenuItemId"] }
        var preferencesWindow: XCUIElement { return app.windows["PreferencesWindowId"] }
        var apiKeyField: XCUIElement { return preferencesWindow.textFields["ApiKeyTextFieldId"] }
        
        // Open Preferences window
        statusBarMenu.click()
        preferencesMenu.click()
        
        // Xheck that the api key is the same from the Welcome page setup
        XCTAssertTrue(preferencesWindow.exists)
        XCTAssertTrue(apiKeyField.exists)
        XCTAssertEqual(API_KEY, apiKeyField.value as! String)
    }
    
    func testFirstFailConfiguration() {
        var app = getApp(apiKey: "", hideIcon: false)
        app.launch()
        
        // Main Window UI Elements
        var mainWindow: XCUIElement { return app.windows["MainWindowId"] }
        var apiTokenField: XCUIElement { return mainWindow.textFields["MainApiTokenFieldId"] }
        var hideIconCheckbox: XCUIElement { return mainWindow.checkBoxes["MainHideIconCheckboxId"] }
        var configureButton: XCUIElement { return mainWindow.buttons["MainConfigureButtonId"] }
        var statusIcon: XCUIElement { return mainWindow.images["MainStatusIconId"] }
        var windowCloseButton: XCUIElement { return app.buttons[XCUIIdentifierCloseWindow] }
        
        // Check that the configuration button is disabled and no status icon is visible
        XCTAssertFalse(configureButton.isEnabled)
        XCTAssertFalse(statusIcon.exists)
        
        // fill in the api key in the api token field and press enter to confirm
        apiTokenField.click()
        apiTokenField.typeText("super-invalid-api-key")
        apiTokenField.typeText(XCUIKeyboardKey.enter.rawValue)
        
        // wait for api check rest response to be received
        sleep(2)
        
        // check that the configuration button is NOT enabled and the status icon visible
        XCTAssertFalse(configureButton.isEnabled)
        XCTAssertTrue(statusIcon.isHittable)
        
        // click the close button should quit the application
        windowCloseButton.click()
        XCTAssertEqual(app.state, XCUIApplication.State.notRunning)
    }
    
    func testShowAbout() {
        let app = getApp()
        app.launch()
        
        // Get references to UI items via identifier
        var statusBarMenu: XCUIElement {
            return app.children(matching: .menuBar).element(boundBy: 1).children(matching: .statusItem).element
        }
        var aboutMenu: XCUIElement { return app.menuBars.menuItems["AboutMenuItemId"] }
        var aboutWindow: XCUIElement { return app.dialogs["AboutWindowId"] }
        var aboutNameLabelItem: XCUIElement { return app.staticTexts["AboutAppNameLabelId"] }
        var aboutVersionLabelItem: XCUIElement { return app.staticTexts["AboutVersionLabelId"] }
        var aboutCopyrightLabelItem: XCUIElement { return app.staticTexts["AboutCopyrightLabelId"] }
        var aboutIcon: XCUIElement { return app.images["AboutIconId"] }
        var aboutCloseButton: XCUIElement { return app.buttons[XCUIIdentifierCloseWindow] }
        
        // Open About Window
        statusBarMenu.click()
        aboutMenu.click()
        XCTAssertTrue(aboutWindow.exists)
        
        // Test About Window labels' availability
        aboutNameLabelItem.click()
        aboutVersionLabelItem.click()
        aboutCopyrightLabelItem.click()
        aboutIcon.click()
        
        // Test About Window labels' content
        XCTAssertEqual(aboutNameLabelItem.value as! String, "BitURL")
        XCTAssertTrue(
            NSRegularExpression.test(
                aboutVersionLabelItem.value as! String,
                for: #"Version [\d\.]+, Build \d+"#
            )
        )
        XCTAssertTrue(
            NSRegularExpression.test(
                aboutCopyrightLabelItem.value as! String,
                for: #"Copyright © 2019 Roberto Mauro\. All rights reserved"#
            )
        )

        // Close the About Window
        aboutCloseButton.click()
        XCTAssertFalse(aboutWindow.exists)
    }
    
    func testQuitByMenu() {
        let app = getApp()
        app.launch()
        
        var statusBarMenu: XCUIElement {
            return app.children(matching: .menuBar).element(boundBy: 1).children(matching: .statusItem).element
        }
        var quitMenu: XCUIElement {
            return app.menuBars.menuItems["QuitMenuItemId"]
        }

        statusBarMenu.click()
        quitMenu.click()
        
        XCTAssertEqual(app.state, XCUIApplication.State.notRunning)
    }
    
    func testShouldSavePreferences() {
        let expectedApiKey = "test-api-key"
        
        let app = getApp(hideIcon: false, hideNotifications: false)
        app.launch()
        
        // Setup UI Element
        var statusBarMenu: XCUIElement {
            return app.children(matching: .menuBar).element(boundBy: 1).children(matching: .statusItem).element
        }
        var preferencesMenu: XCUIElement { return app.menuBars.menuItems["PreferencesMenuItemId"] }
        var preferencesWindow: XCUIElement { return app.windows["PreferencesWindowId"] }
        var apiKeyField: XCUIElement { return preferencesWindow.textFields["ApiKeyTextFieldId"] }
        var preferencesCloseButton: XCUIElement { return app.buttons[XCUIIdentifierCloseWindow] }
        var hideIconCheckbox: XCUIElement { return preferencesWindow.checkBoxes["PreferencesHideIconId"] }
        var hideNotificationsCheckbox: XCUIElement { return preferencesWindow.checkBoxes["PreferencesHideNotificationsId"] }
        
        // Open Preferences Window
        statusBarMenu.click()
        preferencesMenu.click()
        
        // preferences window should be visible
        XCTAssertTrue(preferencesWindow.exists)
        
        // test api token reachability and editability
        XCTAssertTrue(apiKeyField.isHittable)
        XCTAssertTrue(apiKeyField.isEnabled)
        XCTAssertEqual(apiKeyField.value as! String, API_KEY)
        
        // Update the Api Key
        apiKeyField.click()
        apiKeyField.doubleClick()
        apiKeyField.typeText(expectedApiKey)
        apiKeyField.typeText(XCUIKeyboardKey.enter.rawValue)
        
        // Verify that hideIcon and hideNotifications are not checked
        XCTAssertFalse(hideNotificationsCheckbox.value as! Bool)
        XCTAssertFalse(hideIconCheckbox.value as! Bool)
        
        // Change the hideIcon and hideNotification status
        hideNotificationsCheckbox.click()
        hideIconCheckbox.click()
        
        // hideIcon checkbox click should close the Preferences
        XCTAssertFalse(preferencesWindow.exists)
        
        // Reopen Preferences
        statusBarMenu.click()
        preferencesMenu.click()
        
        // Verify that Preferences is open and that the previous Api key is still set
        XCTAssertTrue(preferencesWindow.exists)
        XCTAssertEqual(expectedApiKey, apiKeyField.value as! String)
        XCTAssertTrue(hideNotificationsCheckbox.value as! Bool)
        XCTAssertTrue(hideIconCheckbox.value as! Bool)
        
        // Close Preferences Window
        preferencesCloseButton.click()
        XCTAssertFalse(preferencesWindow.exists)
    }

    func testLaunchPerformance() {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
}

extension NSRegularExpression {
    /**
     Returns all matches for pattern in string.
     - Parameter for: Regulare expression pattern
     - Parameter in: Match string
     - Returns: Array of matched Strings
     */
    static func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    /**
     Return true if regex test pass, otherwise false.
     - Parameter _: The string to be tested
     - Parameter for: Regular expression pattern
     - Returns: True if test pass, otherwise false
     */
    static func test(_ text: String, for regex: String) -> Bool {
        return NSRegularExpression.matches(for: regex, in: text).count > 0
    }
}
