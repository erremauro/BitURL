//
//  AboutViewController.swift
//  BitURL
//
//  Created by Roberto Mauro on 02/11/2019.
//  Copyright © 2019 Roberto Mauro. All rights reserved.
//

import Cocoa

class AboutViewController: NSViewController {

    @IBOutlet weak var versionLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appVersionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        
        versionLabel.stringValue = "Version \(appVersionString), Build \(buildNumber)"
    }
    
}
