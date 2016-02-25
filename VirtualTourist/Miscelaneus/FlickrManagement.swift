//
//  FlickrManagement.swift
//  VirtualTourist
//
//  Created by Daniela Velasquez on 2/25/16.
//  Copyright © 2016 Mahisoft. All rights reserved.
//

import UIKit
import Foundation

class FlickrManagement: NSObject {
    
    let BASE_URL = "https://api.flickr.com/services/rest/"
    let API_KEY = "e681d80d16a7e0949ff06fad880ea7b1"
    
    let METHOD_NAME = "flickr.photos.search"
    
    let PHOTOS_PER_PAGE = 25
    let MAX_FLICKR = 100
    let SAFE_SEARCH = "1"
    let DATA_FORMAT = "json"
    let NO_JSON_CALLBACK = "1"
    
    
    class func sharedInstance() -> FlickrManagement {
        
        struct Singleton {
            static var instance = FlickrManagement()
        }
        
        return Singleton.instance
    }
    
    func photosSearch(pin: PinLocation, connection: ConnectionAPI) {
        
        let methodArguments: [String:AnyObject] = [
            "method": METHOD_NAME,
            "bbox": createBBoxString(pin.latitude, longitude: pin.longitude),
            "safe_search": SAFE_SEARCH,
            "per_page": PHOTOS_PER_PAGE,
            "page": PHOTOS_PER_PAGE,
            "api_key": API_KEY,
            "format": DATA_FORMAT,
            "nojsoncallback": NO_JSON_CALLBACK,
        ]
        
        connection.get(BASE_URL, parametersArray: methodArguments, serverTag: "flickr")
    }
    
    func createBBoxString(latitude: Double, longitude: Double) -> String {
        
        let topLat = min(latitude + 1.0, 90.0)
        let bottomLat = max(latitude - 1.0, -90.0)
        
        let topLon = min(longitude + 1.0, 180.0)
        let bottomLon = max(longitude - 1.0, -180)
        
        return "\(bottomLon),\(bottomLat),\(topLon),\(topLat)"
    }
    
}

