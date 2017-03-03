//
//  RootViewController.swift
//  PhotoBrowser
//
//  Created by Anna Dickinson on 3/2/17.
//  Copyright © 2017 Wacky Banana Software. All rights reserved.
//

import UIKit

// Initial screen of the app.  Contains a refresh button and an instance of the browser.

class RootViewController: UIViewController {
    private static let browserEmbedSegueIdentifier = "BrowserEmbedSegue"

    // Receive button taps.
    @IBAction func reloadButtonPressed(_ sender: Any) {
        browserCollectionViewController.refresh()
    }

    // iOS calls this to deliver an the BrowserCollectionViewController it instantiates from the storyboard.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == RootViewController.browserEmbedSegueIdentifier,
            let destination = segue.destination as? BrowserCollectionViewController {
            browserCollectionViewController = destination
            return
        }

        // Shouldn't receive any other segues
        fatalError("Invalid segue \(segue)")
    }
    
    // Reference to the BrowserCollectionViewController instance received above.
    private var browserCollectionViewController: BrowserCollectionViewController!
}
