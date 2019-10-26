//
//  PasteboardService.swift
//  Bitly
//
//  Created by Roberto Mauro on 26/10/2019.
//  Copyright © 2019 Roberto Mauro. All rights reserved.
//

import Cocoa

protocol IPasteboardService {
    func setString(_ string: String)
}

class PasteboardService: IPasteboardService {
    func setString(_ string: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(string, forType: .string)
    }
}
