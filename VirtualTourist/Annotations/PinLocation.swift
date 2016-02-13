//
//  PinLocation.swift
//  VirtualTourist
//
//  Created by Daniela Velasquez on 2/13/16.
//  Copyright © 2016 Mahisoft. All rights reserved.
//


import UIKit

struct PinLocation {
    
    var uniqueKey:String
    var firstName:String
    var lastName:String
    var mapString:String
    var mediaURL:String?
    var latitude:Double
    var longitude:Double
    
    
    func toJSON() -> [String : AnyObject]{
        
        let dic:NSMutableDictionary = NSMutableDictionary()
        
        dic["uniqueKey"] = self.uniqueKey
        dic["firstName"] = self.firstName
        dic["lastName"]  = self.lastName
        dic["mapString"] = self.mapString
        dic["mediaURL"]  = self.mediaURL
        dic["latitude"]  = self.latitude
        dic["longitude"] = self.longitude
        
        let json:NSDictionary = dic
        
        return json as! [String : AnyObject]
    }
    
}