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
    
    @IBAction func showGeneralView(_ sender: NSToolbarItem) {}
    
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
