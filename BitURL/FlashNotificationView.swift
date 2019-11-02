//
//  FlashNotificationView.swift
//  BitURL
//
//  Created by Roberto Mauro on 01/11/2019.
//  Copyright © 2019 Roberto Mauro. All rights reserved.
//

import Cocoa

class FlashNotificationView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        self.layer?.cornerRadius = 20.0
    }
    
}
