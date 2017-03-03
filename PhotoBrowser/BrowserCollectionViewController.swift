//
//  BrowserCollectionViewController.swift
//  PhotoBrowser
//
//  Created by Anna Dickinson on 3/1/17.
//  Copyright © 2017 Wacky Banana Software. All rights reserved.
//

import UIKit

// Side-scrolling collection view of images.

class BrowserCollectionViewController: UICollectionViewController {
    private static let imageCellReuseIdenfifier = "imageCell"
    
    // Specific things this screen can be doing
    private enum State {
        case new
        case displayingMessage(String)
        case displayingPhotos
    }
    
    // Manage and present views based on the current state
    private var state = State.new {
        didSet {
            switch (state, oldValue) {
            case (.new, _):
                collectionView?.isHidden = true
            case (.displayingMessage(let message), .displayingMessage):
                dismiss(animated: true)
                collectionView?.isHidden = true
                let messageViewController = MessageViewController.createWith(message: message)
                present(messageViewController, animated: true)
            case (.displayingMessage(let message), _):
                collectionView?.isHidden = true
                let messageViewController = MessageViewController.createWith(message: message)
                present(messageViewController, animated: true)
            case (.displayingPhotos, .displayingMessage):
                dismiss(animated: true)
                collectionView?.isHidden = false
            case (.displayingPhotos, _):
                // Invalid transition -- check for safety!
                fatalError("Invalid state transition")
            }
        }
    }
    
    // Photos retreived from Flickr
    private var photoList: [Flickr.Photo] = [] {
        didSet { collectionView?.reloadData() }
    }

    // Load (or reload) the Flickr feed
    func refresh() {
        DispatchQueue.main.async {
            self.photoList = []
            self.state = .displayingMessage("Fetching images from Flickr...")
            
            Flickr.fetchPhotoList {
                [weak self] result in
                guard let strong_self = self else { return }
                
                DispatchQueue.main.async {
                    switch result {
                    case .success(let photoList):
                        strong_self.photoList = photoList
                        strong_self.state = .displayingPhotos
                    case .failure(let error):
                        strong_self.state = .displayingMessage("Could not load photos from Flickr\n(\(error))")
                    }
                }
            }
        }
    }

    
    // iOS view lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
        state = .new
        refresh()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        (collectionViewLayout as! UICollectionViewFlowLayout).itemSize = view.frame.size
    }

    
    // Delegate methods for populating the collection view

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoList.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.item < photoList.count else {
            fatalError("Invalid indexPath \(indexPath)")
        }

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BrowserCollectionViewController.imageCellReuseIdenfifier, for: indexPath) as? BrowserPhotoCell else {
            fatalError("Could not create cell")
        }
        
        cell.photo = photoList[indexPath.item]
    
        return cell
    }
    
    
    // Delegate methdos for interacting with the collection view

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < photoList.count else {
            fatalError("Invalid indexPath \(indexPath)")
        }
        
        let photo = photoList[indexPath.item]

        let message: String
        if let date = photo.datetaken {
            message = "\(photo.title)\n\(date)\n\(photo.ownername)"
        }
        else {
            message = "\(photo.title)\n\(photo.ownername)"
        }

        let alertController = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default) {
            _ in
            self.dismiss(animated: true, completion: nil)
        })
        present(alertController, animated: true, completion: nil)
    }
}
