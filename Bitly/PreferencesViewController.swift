//
//  PreferencesViewController.swift
//  Bitly
//
//  Created by Roberto Mauro on 20/10/2019.
//  Copyright © 2019 Roberto Mauro. All rights reserved.
//

import Cocoa

extension Notification.Name {
    static let hideIconChanged = Notification.Name("hideIconChanged")
}

class PreferencesViewController: NSViewController {
    let userDefaults = UserDefaultsService.shared
    let notificationServices = NotificationService()
    
    @IBOutlet weak var iconStatusLabel: NSTextField!
    @IBOutlet weak var apiKeyTextField: NSTextField!
    @IBOutlet weak var iconState: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        iconStatusLabel.stringValue = NSLocalizedString("Appereance", comment: "Appereance label")
        iconState.title = NSLocalizedString("Hide dock icon", comment: "Hide dock icon label")
        
        apiKeyTextField.stringValue = userDefaults.apiKey 
        let isHidden = userDefaults.hideIcon 
        iconState.state = isHidden ? NSControl.StateValue.on : NSControl.StateValue.off
    }
    
    @IBAction func textDidChange(_ sender: NSTextField) {
        switch sender.identifier?.rawValue {
        case "ApiKeyTextFieldId":
            userDefaults.apiKey = sender.stringValue
            notificationServices.post(name: .apiKeyChanged, userInfo: ["apiKey": sender.stringValue])
        default:
            break
        }
    }
    
    @IBAction func iconStateDidUpdate(_ sender: NSButton) {
        let shouldHide = sender.state == NSControl.StateValue.on ? true : false
        userDefaults.hideIcon = shouldHide
        notificationServices.post(name: .hideIconChanged, userInfo: ["hideIcon": shouldHide])
    }
}
