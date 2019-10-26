//
//  URLEventController.swift
//  Bitly
//
//  Created by Roberto Mauro on 24/10/2019.
//  Copyright © 2019 Roberto Mauro. All rights reserved.
//

import Cocoa

enum URLEventActionName {
    case noAction
    case shorten
}

struct URLEventAction {
    let name: URLEventActionName
    let params: [AnyHashable: Any]?
}

class URLEventController {
    
    var notificationService: INotificationService!
    var apiService: IBitlyApi!
    var pasteboardService: IPasteboardService!
    
    init(using apiService: IBitlyApi = BitlyApi.shared, notificationService: INotificationService = NotificationService(), pasteboardService: IPasteboardService = PasteboardService()) {
        self.apiService = apiService
        self.notificationService = notificationService
        self.pasteboardService = pasteboardService
    }
    
    @objc func handleEvent(event: NSAppleEventDescriptor, replyEvent: NSAppleEventDescriptor) {
        guard let appleEventDescription = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject)) else {
            return
        }
        
        guard let appleEventURLString = appleEventDescription.stringValue else {
            return
        }
        
        let appleEventURL = URL(string: appleEventURLString)
        let actionURL = appleEventURL!.absoluteString
        
        self.performAction(for: actionURL)
    }
    
    func performAction(for url: String) {
        guard let action = urlEventAction(for: url) else { return }
        switch action.name {
        case .shorten:
            self.shorten(url: action.params?["url"] as! String)
            break
        default:
            break
        }
    }
    
    private func shorten(url: String) {
        apiService.shorten(url: url) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let shortURL):
                    self.pasteboardService.setString(shortURL.link)
                    
                    NSApplication.shared.hide(self)
                    
                    self.notificationService.notifySuccess(title: "URL Shortened Sucessfully", message: shortURL.link)
                    break
                case .failure( _):
                    NSApplication.shared.hide(self)
                    self.notificationService.notifyFailure(title: "An Error Occured", message: "Unable to shorten url")
                    break
                }
            }
        }
    }
    
    private func urlEventAction(for url: String) -> URLEventAction? {
        let urlComponents = url.replacingOccurrences(of: "bitly://", with: "").split(separator: "/", maxSplits: 1, omittingEmptySubsequences: true)
        
        let stringActionName = urlComponents[0].lowercased()
        let stringParams = urlComponents[1]
        var params: [AnyHashable: Any]?
        var actionName: URLEventActionName = .noAction
        
        switch stringActionName {
        case "shorten":
            actionName = .shorten
            params = ["url": String(stringParams)]
        default:
            actionName = .noAction
        }
        
        return URLEventAction(name: actionName, params: params)
    }
}
