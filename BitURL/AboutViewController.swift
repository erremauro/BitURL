//
//  AboutViewController.swift
//  BitURL
//
//  Created by Roberto Mauro on 02/11/2019.
//  Copyright © 2019 Roberto Mauro. All rights reserved.
//

import Cocoa

class AppInfo {
    static let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
    static var version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    static var copyright = Bundle.main.object(forInfoDictionaryKey: "NSHumanReadableCopyright") as! String
    static var build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    static let versionDescription = "Version \(AppInfo.version), Build \(AppInfo.build)"
}

class AboutViewController: NSViewController {

    @IBOutlet weak var appNameLabel: NSTextField!
    @IBOutlet weak var versionLabel: NSTextField!
    @IBOutlet weak var copyrightLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        appNameLabel.stringValue = AppInfo.name
        versionLabel.stringValue = AppInfo.versionDescription
        copyrightLabel.stringValue = AppInfo.copyright
    }
}
