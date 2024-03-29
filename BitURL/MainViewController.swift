//
//  ViewController.swift
//  BitURL
//
//  Created by Roberto Mauro on 20/10/2019.
//  Copyright © 2019 Roberto Mauro. All rights reserved.
//

import Cocoa

enum ApiKeyState {
    case progress
    case stopped
    case success
    case failure
}

class MainViewController: NSViewController, NSWindowDelegate {
    
    let apiService = BitlyApi()
    let userDefaults = UserDefaultsService.shared
    var apiKey = ""
    
    @IBOutlet weak var appIconView: NSImageView!
    @IBOutlet weak var doneButton: NSButton!
    @IBOutlet weak var apiKeyTextField: NSTextField!
    @IBOutlet weak var hideDockIconButton: NSButton!
    @IBOutlet weak var statusIconView: NSImageView!
    @IBOutlet weak var spinIndicator: NSProgressIndicator!
    @IBOutlet weak var descriptionTextView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton.title = NSLocalizedString("Done", comment: "Done button label")
        apiKeyTextField.placeholderString = NSLocalizedString("TokenPlaceholder", comment: "Token placeholder description")
        hideDockIconButton.title = NSLocalizedString("Hide dock icon", comment: "Hide dock icon label")
        hideDockIconButton.state = userDefaults.hideIcon ? NSControl.StateValue.on : NSControl.StateValue.off
        descriptionTextView.string = NSLocalizedString("WelcomeDescription", comment: "Welcome Page Description")
        descriptionTextView.alignment = NSTextAlignment.center
        descriptionTextView.font = NSFont.systemFont(ofSize: 14.0)
        updateStatusIcon(.stopped)
    }
    
    override func viewWillAppear() {
        self.view.window?.delegate = self
    }
    
    @IBAction func textFieldDidChange(_ sender: NSTextField) {
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
            }
        }
        
    }
    
    @IBAction func doneButtonClicked(_ sender: NSButton) {
        print("Will set apiKey: \(apiKey)")
        UserDefaultsService.shared.apiKey = apiKey
        NotificationService.shared.post(name: .apiKeyChanged, userInfo: ["apiKey": apiKey])
        
        let shouldHideDockIcon = hideDockIconButton.state == NSControl.StateValue.on ? true : false
        
        if (userDefaults.hideIcon != shouldHideDockIcon) {
            UserDefaultsService.shared.hideIcon = hideDockIconButton.state == NSControl.StateValue.on ? true : false
            NotificationService.shared.post(name: .hideIconChanged, userInfo: ["hideIcon": shouldHideDockIcon])
        }
        self.view.window?.orderOut(self)
    }
    
    func windowWillClose(_ notification: Notification) {
        if (UserDefaultsService.shared.apiKey == "") {
            NSApplication.shared.terminate(self)
        }
    }
    
    func updateStatusIcon(_ state: ApiKeyState) {
        spinIndicator.isHidden = state != .progress
        if (state == .progress) {
            spinIndicator.startAnimation(self)
        } else {
            spinIndicator.stopAnimation(self)
        }
        
        self.statusIconView.isHidden = state == .progress || state == .stopped
        self.statusIconView.image = state == .success ? #imageLiteral(resourceName: "SuccessIcon") : #imageLiteral(resourceName: "FailureIcon")
        self.doneButton.isEnabled = state == .success ? true : false
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

