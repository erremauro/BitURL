//
//  ViewController.swift
//  Bitly
//
//  Created by Roberto Mauro on 20/10/2019.
//  Copyright © 2019 Roberto Mauro. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet var searchField: NSTextField!

    
    @IBAction func onSearch(_ sender: NSTextField) {
        print("searching for: \(searchField.stringValue)")
        BitlyApi.shared.shorten(url: searchField.stringValue) { result in
            switch result {
            case .success(let shortLink):
                print("success: \(shortLink)")
                break
            case .failure(let error):
                print("shortLink failure: \(error)")
                break
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

