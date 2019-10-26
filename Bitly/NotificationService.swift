//
//  NotificationService.swift
//  Bitly
//
//  Created by Roberto Mauro on 26/10/2019.
//  Copyright © 2019 Roberto Mauro. All rights reserved.
//

import Cocoa

class NotificationService: INotificationService {
    var notificationCenter: IUserNotificationCenter!
    static var shared: INotificationService = NotificationService()
    
    init(using notificationCenter: IUserNotificationCenter = UserNotificationCenter.shared) {
        self.notificationCenter = notificationCenter
    }
    
    func notifySuccess(title: String, message: String) {
        let notification = URLEventNotification(withTitle: title, message: message)
        self.notificationCenter.deliver(notification)
    }
    
    func notifyFailure(title: String, message: String) {
        let notification = URLEventNotification(withTitle: title, message: message, name: .actionFailure)
        self.notificationCenter.deliver(notification)
    }
    
    func addObserver(_ observer: Any, selector: Selector, name: Notification.Name) {
        self.notificationCenter.addObserver(observer, selector: selector, name: name)
    }
    
    func post(name: Notification.Name, userInfo: [AnyHashable: Any]?) {
        self.notificationCenter.post(name: name, userInfo: userInfo)
    }
}

class UserNotificationCenter: IUserNotificationCenter {
    static var shared: IUserNotificationCenter = UserNotificationCenter()
    
    func deliver(_ aNotification: NSUserNotification) {
        NSUserNotificationCenter.default.deliver(aNotification)
    }
    
    func addObserver(_ observer: Any, selector: Selector, name: Notification.Name) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: name, object: nil)
    }
    
    func post(name: Notification.Name, userInfo: [AnyHashable: Any]?) {
        NotificationCenter.default.post(name: name, object: nil, userInfo: userInfo)
    }
}

// MARK: Protocols

protocol IUserNotificationCenter {
    static var shared: IUserNotificationCenter { get }
    func deliver(_ aNotification: NSUserNotification)
    func addObserver(_ observer: Any, selector: Selector, name: Notification.Name)
    func post(name: Notification.Name, userInfo: [AnyHashable: Any]?)
}

protocol INotificationService {
    static var shared: INotificationService { get }
    func notifySuccess(title: String, message: String)
    func notifyFailure(title: String, message: String)
    
    func addObserver(_ observer: Any, selector: Selector, name: Notification.Name)
    func post(name: Notification.Name, userInfo: [AnyHashable: Any]?)
}

// MARK: Notifications

class URLEventNotification : NSUserNotification {
    required init(withTitle subtitle: String, message: String, name: Notification.Name = .actionCompleted) {
        super.init()
        self.identifier = UUID().uuidString
        self.title = "Bitly"
        self.subtitle = subtitle
        self.informativeText = message
        self.soundName = NSUserNotificationDefaultSoundName
    }
}

// MARK: Extensions

extension Notification.Name {
    static let didShortenURL = Notification.Name(".didShortenURL")
}

extension Notification.Name {
    static let actionCompleted = Notification.Name("actionCompleted")
    static let actionFailure = Notification.Name("actionFailure")
}
