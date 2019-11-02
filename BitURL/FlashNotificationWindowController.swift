//
//  FlashNotificationWindowController.swift
//  BitURL
//
//  Created by Roberto Mauro on 01/11/2019.
//  Copyright © 2019 Roberto Mauro. All rights reserved.
//

import Cocoa

class FlashNotificationWindowController: NSWindowController {

    var viewController: FlashNotificationViewController?
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.window?.backgroundColor = .clear
        self.window?.isOpaque = false
        self.window?.level = .floating
                
        self.viewController = self.window?.contentViewController as? FlashNotificationViewController
    }
    
    var title: String? {
        get {
            return viewController?.notificationTitleTextField?.stringValue
        }
        set {
            viewController?.notificationTitleTextField?.stringValue = newValue!
        }
    }
    
    var icon: NSImage? {
        get {
            return viewController?.notificationIconView?.image
        }
        set {
            viewController?.notificationIconView?.image = newValue!
        }
    }
    
    func fadeIn(_ sender: Any?) {
        var alpha = CGFloat(0.0)
        self.window?.alphaValue = alpha
        self.window?.makeKeyAndOrderFront(sender)
        for _ in 0...10 {
            alpha += 0.1
            self.window?.alphaValue = alpha
            Thread.sleep(forTimeInterval: 0.020)
        }
    }
    
    func fadeOut(_ sender: Any?) {
        var alpha = CGFloat(1.0)
        self.window?.alphaValue = alpha
        self.window?.makeKeyAndOrderFront(sender)
        for _ in 0...10 {
            alpha -= 0.1
            self.window?.alphaValue = alpha
            Thread.sleep(forTimeInterval: 0.020)
        }
    }
}
