//
//  Settings.swift
//  BitURL
//
//  Created by Roberto Mauro on 26/10/2019.
//  Copyright © 2019 Roberto Mauro. All rights reserved.
//

import Cocoa

protocol ISettings {
    var apiKey: String { get set }
    var hideIcon: Bool { get set }
    var hideNotifications: Bool { get set}
}

class SettingsContainer: ISettings {
    private struct Keys {
        static let apiKey = "apiKey"
        static let hideIcon = "hideIcon"
        static let hideNotifications = "hideNotifications"
    }
    
    var apiKey: String {
        get {
            UserDefaults.standard.string(forKey: Keys.apiKey) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.apiKey)
        }
    }
    
    var hideIcon: Bool {
        get {
            UserDefaults.standard.bool(forKey: Keys.hideIcon) 
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.hideIcon)
        }
    }
    
    var hideNotifications: Bool {
        get {
            UserDefaults.standard.bool(forKey: Keys.hideNotifications)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.hideNotifications)
        }
    }
}

class UserDefaultsService {
    static let shared = UserDefaultsService()
    private var settings: ISettings
    
    init(settings: ISettings = SettingsContainer()) {
        self.settings = settings
    }
    
    var apiKey: String {
        get { return settings.apiKey }
        set { settings.apiKey = newValue }
    }
    
    var hideIcon: Bool {
        get { return settings.hideIcon }
        set { settings.hideIcon = newValue }
    }
    
    var hideNotifications: Bool {
        get { return settings.hideNotifications }
        set { settings.hideNotifications = newValue }
    }
}
