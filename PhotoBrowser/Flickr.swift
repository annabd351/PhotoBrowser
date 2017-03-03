//
//  Flickr.swift
//  PhotoBrowser
//
//  Created by Anna Dickinson on 3/1/17.
//  Copyright © 2017 Wacky Banana Software. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
import SwiftyJSON

// Connect to the Flickr API

struct Flickr {
    private static let endpoint = "https://api.flickr.com/services/rest/"

    private static let parameters: Parameters = [
        "method" : "flickr.photos.getRecent",
        "extras": "url_l, owner_name, date_taken",
        "format": "json",
        "api_key": "YOU API KEY GOES HERE",
        "nojsoncallback": 1
    ]
    
    // Fetch a list of photos from Flickr's recent photos feed.  
    // Asynchronously return the result via a completion closure.
    static func fetchPhotoList(completion: @escaping (Result<[Photo]>)->()) {
        Alamofire.request(endpoint, method: .get, parameters: Flickr.parameters).responseJSON {
                    response in
                    switch response.result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(let value):
                        // Construct an array of Photo objects from the appropriate chunk of JSON
                        let photoList = JSON(value)["photos"]["photo"].map {
                            // Create an object
                            Photo(json: $0.1)
                        }.filter {
                            // Remove objects which couldn't be constructed due to invalid (or unexpected) JSON data
                            $0 != nil
                        }.map {
                            // "Force unwrap" the result -- this is a Swift-specific operation which returns 
                            // the underlying value of an optional type (an optional type may or may not 
                            // contain a valid value;  if it doesn't contain a value, it's nil).
                            // Here, we know the input contains a valid value because we filtered out the nils.
                            $0!
                        }
                        completion(.success(photoList))
                    }
                }
    }

    // Fetch the displayable image from a Photo.
    // Asynchronously return the result via a completion closure.
    // Also returns the original photo -- needed to reconcile out-of-order operations.
    static func fetchImage(forPhoto: Photo, completion: @escaping (Result<UIImage>,Photo)->()) {
        Alamofire.request(forPhoto.url_l).responseImage {
            response in
            completion(response.result, forPhoto)
        }
    }

    // Immutable, statically-typed representation of a photo returned from flickr.photos.getRecent
    struct Photo: Equatable {
        let url_l: String
        let ownername: String
        let datetaken: String?
        let title: String
        private let id: String
        
        // Construct by deserializing a JSON representation.
        init?(json: JSON) {
            if let url_l = json["url_l"].string,
                let ownername = json["ownername"].string,
                let title = json["title"].string,
                let datetaken = json["datetaken"].string,
                let datetakenunknown = json["datetakenunknown"].string,
                let id = json["id"].string
            {
                self.url_l = url_l
                self.ownername = ownername
                self.datetaken = datetakenunknown == "0" ? datetaken : nil
                self.title = title
                self.id = id
            } else {
                return nil
            }
        }
        
        static func ==(lhs: Photo, rhs: Photo) -> Bool {
            return lhs.id == rhs.id
        }
    }
}
