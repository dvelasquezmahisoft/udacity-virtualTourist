//
//  PinLocation.swift
//  VirtualTourist
//
//  Created by Daniela Velasquez on 2/13/16.
//  Copyright © 2016 Mahisoft. All rights reserved.
//


import UIKit

struct PinLocation {
    
    var latitude:Double
    var longitude:Double
    
    
    func toJSON() -> [String : AnyObject]{
        
        let dic:NSMutableDictionary = NSMutableDictionary()
        
        dic["latitude"]  = self.latitude
        dic["longitude"] = self.longitude
        
        let json:NSDictionary = dic
        
        return json as! [String : AnyObject]
    }
    
}