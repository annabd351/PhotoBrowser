//
//  BrowserPhotoCell.swift
//  PhotoBrowser
//
//  Created by Anna Dickinson on 3/1/17.
//  Copyright © 2017 Wacky Banana Software. All rights reserved.
//

import UIKit

// Indivual cell which displays the image from a Photo

class BrowserPhotoCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!
    
    // Things this cell can be doing
    private enum State {
        case new
        case loading
        case displaying
        case error
    }

    // Manage views based on the state
    private var state = State.new {
        didSet {
            switch (state, oldValue) {
            case (.new, _):
                imageView.isHidden = true
                activityIndicatorView.isHidden = true
                errorLabel.isHidden = true
            case (.loading, _):
                imageView.isHidden = true
                activityIndicatorView.isHidden = false
                errorLabel.isHidden = true
            case (.displaying, .loading), (.displaying, .new), (.displaying, .error):
                imageView.alpha = 0.0
                imageView.isHidden = false
                activityIndicatorView.isHidden = true
                errorLabel.isHidden = true
                UIView.animate(withDuration: 0.5) {
                    self.imageView.alpha = 1.0
                }
            case (.displaying, .displaying):
                // Views are already in the correct state.
                break
            case (.error, _):
                imageView.isHidden = true
                activityIndicatorView.isHidden = true
                errorLabel.isHidden = false
            }
        }
    }
    
    // Set by collection view to display a Photo
    var photo: Flickr.Photo? {
        didSet {
            if photo == oldValue {
                // We've already loaded (or are currently loading) this Photo.
                // Don't need to re-fetch.
                state = .displaying
                return
            }

            if let photo = photo {
                state = .loading
                Flickr.fetchImage(forPhoto: photo) {
                    [weak self] result, requestedPhoto in
                    guard let strong_self = self else { return }

                    DispatchQueue.main.async {
                        // Make sure this response corresponds to the Photo we're
                        // intending to display -- requests can complete in an unexpected order
                        guard strong_self.photo == requestedPhoto else {
                            return
                        }

                        switch result {
                        case .success(let image):
                            strong_self.imageView.image = image
                            strong_self.state = .displaying
                        case .failure:
                            strong_self.state = .error
                        }
                    }
                }
            }
        }
    }
    
    // iOS view lifecycle methods

    override func awakeFromNib() {
        super.awakeFromNib()
        state = .new
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        state = .new
    }
}
