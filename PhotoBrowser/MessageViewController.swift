//
//  MessageViewController.swift
//  PhotoBrowser
//
//  Created by Anna Dickinson on 3/2/17.
//  Copyright © 2017 Wacky Banana Software. All rights reserved.
//

import UIKit

// Display a message 

class MessageViewController: UIViewController {
    @IBOutlet weak var messageLabel: UILabel!
    private var message: String!
    
    // Factory method to instantiate a MessageViewController set to display a specific message.
    static func createWith(message: String) -> MessageViewController {
        if let newInstance = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MessageViewController") as? MessageViewController {
            newInstance.message = message
            return newInstance
        }
        else {
            fatalError("Could not instantiate view controller from storyboard")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        messageLabel.text = message
    }
}
