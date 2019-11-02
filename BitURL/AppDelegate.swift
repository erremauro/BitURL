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
    
    @IBAction func showPreferences(sender: NSMenuItem) {
        handleShowPreferences()
    }
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        NSAppleEventManager.shared().setEventHandler(urlEventController, andSelector: #selector(urlEventController.handleEvent(event:replyEvent:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
        
        notificationService.addObserver(self, selector: #selector(handleHideIconChanged(_:)), name: .hideIconChanged)
        notificationService.addObserver(self, selector: #selector(didShortenURL(_:)), name: .didShortenURL)
        notificationService.addObserver(self, selector: #selector(notificationDidExpired(_:)), name: .notificationDidExpired)
        if (userDefaults.apiKey == "") {
            let mainWC = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "MainWindowId") as! MainWindowController
            mainWC.showWindow(self)
        }
    }
    
    @objc func handleHideIconChanged(_ notification: Notification) {
        guard let newValue = notification.userInfo?["hideIcon"] as? Bool else {
            return
        }
                
        toggleIconState(isHidden: newValue)
    }
    
    @objc func didShortenURL(_ notification: Notification) {
        if (notificationWC == nil) {
            notificationWC = NSStoryboard(name: "FlashNotification", bundle: .main).instantiateController(withIdentifier: "FlashNotificationWindowId") as? FlashNotificationWindowController
        }
        
        guard let newValue = notification.userInfo?["message"] as? String else {
            return
        }
        
        notificationWC?.title = NSLocalizedString("Copied", comment: "Copied label")
        notificationWC?.icon = #imageLiteral(resourceName: "LinkIcon")
        notificationWC?.fadeIn(self)
    }
    
    @objc func notificationDidExpired(_ notification: Notification) {
        notificationWC?.fadeOut(self)
    }
    
    func toggleIconState(isHidden: Bool? = nil) {
        let hideStatus = isHidden != nil ? isHidden : userDefaults.hideIcon
        
        if (hideStatus!) {
            NSApp.setActivationPolicy(NSApplication.ActivationPolicy.accessory)
        } else {
            NSApp.setActivationPolicy(NSApplication.ActivationPolicy.regular)
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let statusBar = NSStatusBar.system
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)
        statusBarItem.button?.image = #imageLiteral(resourceName: "StatusBarIcon")
        
        let statusBarMenu = NSMenu(title: "Bitly StatusBar Menu")
        statusBarItem.menu = statusBarMenu
        statusBarMenu.addItem(
            withTitle: NSLocalizedString("Preferences...", comment: "Preferences label"),
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
