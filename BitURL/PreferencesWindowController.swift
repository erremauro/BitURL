//
//  PreferencesWindowController.swift
//  BitURL
//
//  Created by Roberto Mauro on 20/10/2019.
//  Copyright © 2019 Roberto Mauro. All rights reserved.
//

import Cocoa

class PreferencesWindowController: NSWindowController {
    
    @IBOutlet weak var settingsMenuToolbar: NSToolbar!
    @IBOutlet weak var generalToolbarItem: NSToolbarItem!
    
    // Having thi function wired to the General Toolbar Item will
    // show the icon as active.
    @IBAction func generalToolbarItemClicked(_ sender: NSToolbarItem) {
        // do nothing
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.title = NSLocalizedString("Preferences", comment: "Preferences Window Title")
        
        settingsMenuToolbar.selectedItemIdentifier = generalToolbarItem.itemIdentifier
        generalToolbarItem.label = NSLocalizedString("General", comment: "General label")
    }
    
    func bringToFront() {
      self.window?.center()
      self.window?.makeKeyAndOrderFront(nil)
      NSApp.activate(ignoringOtherApps: true)
    }
}
