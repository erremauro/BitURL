//
//  AppDelegate.swift
//  BitURL
//
//  Created by Roberto Mauro on 20/10/2019.
//  Copyright © 2019 Roberto Mauro. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let notificationService = NotificationService.shared
    let urlEventController = URLEventController()
    let userDefaults = UserDefaultsService.shared
    
    var statusBarItem: NSStatusItem!
    var preferencesWC: PreferencesWindowController?
    var notificationWC: FlashNotificationWindowController?
    var aboutWC: NSWindowController!
    
    @IBAction func showPreferences(_ sender: NSMenuItem) {
        handleShowPreferences()
    }
    
    @IBAction func showAbout(_ sender: NSMenuItem) {
        handleShowAbout()
    }
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        // hand URL Type Scheme call handling to URLEventController
        NSAppleEventManager.shared().setEventHandler(urlEventController, andSelector: #selector(urlEventController.handleEvent(event:replyEvent:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
        
        // Listen for notifications
        notificationService.addObserver(self, selector: #selector(handleHideIconChanged(_:)), name: .hideIconChanged)
        notificationService.addObserver(self, selector: #selector(didShortenURL(_:)), name: .didShortenURL)
        notificationService.addObserver(self, selector: #selector(notificationDidExpired(_:)), name: .notificationDidExpired)
        
        // Show the Welcome Page if no Api key is set
        if (userDefaults.apiKey == "") {
            let mainWC = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "MainWindowId") as! MainWindowController
            mainWC.showWindow(self)
        }
        
        // hide or show the dock icon based on the user preferences
        toggleIconState()
    }
    
    @objc func handleHideIconChanged(_ notification: Notification) {
        guard let newValue = notification.userInfo?["hideIcon"] as? Bool else {
            return
        }
                
        toggleIconState(isHidden: newValue)
    }
    
    @objc func didShortenURL(_ notification: Notification) {
        // if no message has been set, do not show any flash notification
        guard (notification.userInfo?["message"] as? String) != nil else {
            return
        }
        
        // how the flash notification
        if (notificationWC == nil) {
            notificationWC = NSStoryboard(name: "FlashNotification", bundle: .main).instantiateController(withIdentifier: "FlashNotificationWindowId") as? FlashNotificationWindowController
        }
        
        notificationWC?.title = NSLocalizedString("Copied", comment: "Copied label")
        notificationWC?.icon = #imageLiteral(resourceName: "LinkIcon")
        notificationWC?.fadeIn(self)
    }
    
    @objc func notificationDidExpired(_ notification: Notification) {
        notificationWC?.fadeOut(self)
    }
    
    func toggleIconState(isHidden: Bool? = nil) {
        let shouldHide = isHidden != nil ? isHidden : userDefaults.hideIcon
        
        if (shouldHide!) {
            NSApp.setActivationPolicy(NSApplication.ActivationPolicy.accessory)
            preferencesWC?.window?.orderOut(self)
        } else {
            NSApp.setActivationPolicy(NSApplication.ActivationPolicy.regular)
        }
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // configure Status Bar Menu
        let statusBar = NSStatusBar.system
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)
        statusBarItem.button?.image = #imageLiteral(resourceName: "StatusBarIcon")
        
        let statusBarMenu = NSMenu(title: "BitURL StatusBar Menu")
        statusBarItem.menu = statusBarMenu
        
        statusBarMenu.addItem(
            withTitle: NSLocalizedString("About BitURL", comment: "About BitURL label"),
            action: #selector(handleShowAbout),
            keyEquivalent: "")
        statusBarMenu.addItem(NSMenuItem.separator())
        statusBarMenu.addItem(
            withTitle: NSLocalizedString("Preferences...", comment: "Preferences label"),
            action: #selector(handleShowPreferences),
            keyEquivalent: "")
        statusBarMenu.addItem(NSMenuItem.separator())
        statusBarMenu.addItem(
            withTitle: NSLocalizedString("Quit", comment: "Quit label"),
            action: #selector(handleQuitApplication),
            keyEquivalent: "")
    }
        
    @objc func handleShowPreferences() {
        if (preferencesWC == nil) {
            preferencesWC = NSStoryboard(name: "Preferences", bundle: nil).instantiateController(withIdentifier: "PreferencesWindowId") as? PreferencesWindowController
        }
        
        preferencesWC?.showWindow(self)
        preferencesWC?.bringToFront()
    }
    
    @objc func handleShowAbout() {
        if (aboutWC == nil) {
            aboutWC = NSStoryboard(name: "Main", bundle: .main).instantiateController(withIdentifier: "AboutWindowId") as? NSWindowController
        }

        aboutWC?.showWindow(self)
        aboutWC.window?.makeKeyAndOrderFront(self)
    }

    @objc func handleQuitApplication() {
        NSApplication.shared.terminate(self)
    }
}
