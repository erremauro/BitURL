//
//  PreferencesWindowController.swift
//  Bitly
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
        
        settingsMenuToolbar.selectedItemIdentifier = generalToolbarItem.itemIdentifier
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    func bringToFront() {
      self.window?.center()
      self.window?.makeKeyAndOrderFront(nil)
      NSApp.activate(ignoringOtherApps: true)
    }

}
