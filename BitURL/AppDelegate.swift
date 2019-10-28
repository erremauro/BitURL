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
    let urlEventController = URLEventController()
    let userDefaults = UserDefaultsService.shared
    var statusBarItem: NSStatusItem!

    var preferencesWC: PreferencesWindowController?
    
    @IBAction func showPreferences(sender: NSMenuItem) {
        handleShowPreferences()
    }
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        NSAppleEventManager.shared().setEventHandler(urlEventController, andSelector: #selector(urlEventController.handleEvent(event:replyEvent:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
        
        NotificationService.shared.addObserver(self, selector: #selector(handleHideIconChanged(_:)), name: .hideIconChanged)
        toggleIconState()
        
        if (userDefaults.apiKey == "") {
            let mainWC = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "MainWindowId") as! MainWindowController
            mainWC.showWindow(self)
        }
    }
    
    @objc func handleHideIconChanged(_ aNotification: Notification) {
        toggleIconState()
    }
    
    func toggleIconState() {
        if (userDefaults.hideIcon) {
            NSApp.setActivationPolicy(NSApplication.ActivationPolicy.accessory)
        } else {
            NSApp.setActivationPolicy(NSApplication.ActivationPolicy.regular)
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let statusBar = NSStatusBar.system
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)
        statusBarItem.button?.image = #imageLiteral(resourceName: "StatusBarLight")
        statusBarItem.button?.alternateImage = #imageLiteral(resourceName: "StatusBarDark")
        
        let statusBarMenu = NSMenu(title: "Bitly StatusBar Menu")
        statusBarItem.menu = statusBarMenu
        statusBarMenu.addItem(
            withTitle: NSLocalizedString("Preferences", comment: "Preferences label"),
            action: #selector(handleShowPreferences),
            keyEquivalent: "")

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

    @objc func handleQuitApplication() {
        NSApplication.shared.terminate(self)
    }


}

