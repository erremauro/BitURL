//
//  PreferencesViewController.swift
//  BitURL
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
    let apiService = BitlyApi()
    var apiKey: String = ""
    
    @IBOutlet weak var iconStatusLabel: NSTextField!
    @IBOutlet weak var apiKeyTextField: NSTextField!
    @IBOutlet weak var hideDockIconButton: NSButton!
    @IBOutlet weak var statusIconView: NSImageView!
    @IBOutlet weak var spinIndicator: NSProgressIndicator!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        iconStatusLabel.stringValue = NSLocalizedString("Appereance", comment: "Appereance label")
        hideDockIconButton.title = NSLocalizedString("Hide dock icon", comment: "Hide dock icon label")
        
        apiKeyTextField.stringValue = userDefaults.apiKey 
        hideDockIconButton.state = userDefaults.hideIcon ? NSControl.StateValue.on : NSControl.StateValue.off
        
        updateStatusIcon(.stopped)
                
        NotificationService.shared.addObserver(self, selector: #selector(apiKeyDidChange(_:)), name: .apiKeyChanged)
    }
    
    @IBAction func textDidChange(_ sender: NSTextField) {
        switch sender.identifier?.rawValue {
        case "ApiKeyTextFieldId":
            updateStatusIcon(.progress)
            apiKey = sender.stringValue
            apiService.apiKey = apiKey
            apiService.isAuthorized() { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let isAuthorized):
                        if (isAuthorized) {
                            self.updateStatusIcon(.success)
                        } else {
                            self.updateStatusIcon(.failure)
                        }
                        break
                    case .failure(_):
                        self.updateStatusIcon(.failure)
                        break
                    }
                    
                    self.userDefaults.apiKey = self.apiKey
                    self.notificationServices.post(name: .apiKeyChanged, userInfo: ["apiKey": self.apiKey])
                }
            }
        default:
            break
        }
    }
    
    @objc func apiKeyDidChange(_ aNotification: Notification) {
        guard let apiKey = aNotification.userInfo?["apiKey"] as? String else {
            return
        }
        
        if (apiKey != apiKeyTextField.stringValue) {
            apiKeyTextField.stringValue = apiKey
        }
    }
    
    @IBAction func hideDockIconClicked(_ sender: NSButton) {
        let shouldHide = sender.state == NSControl.StateValue.on ? true : false
        userDefaults.hideIcon = shouldHide
        notificationServices.post(name: .hideIconChanged, userInfo: ["hideIcon": shouldHide])
    }
    
    func updateStatusIcon(_ state: ApiKeyState) {
        spinIndicator.isHidden = state != .progress
        if (state == .progress) {
            spinIndicator.startAnimation(self)
        } else {
            spinIndicator.stopAnimation(self)
        }
        
        self.statusIconView.isHidden = state == .progress || state == .stopped
        self.statusIconView.image = state == .success ? #imageLiteral(resourceName: "SuccessIcon") : #imageLiteral(resourceName: "ErrorIcon")
    }
}
