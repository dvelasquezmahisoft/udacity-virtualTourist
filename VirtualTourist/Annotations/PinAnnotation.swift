//
//  PinAnnotation.swift
//  VirtualTourist
//
//  Created by Daniela Velasquez on 2/13/16.
//  Copyright © 2016 Mahisoft. All rights reserved.
//

import MapKit
import CoreData

class PinAnnotation:  NSObject, MKAnnotation {
    
    let id: Int?
    let coordinate: CLLocationCoordinate2D
    
    init(id: Int?, coordinate: CLLocationCoordinate2D) {
        
        self.id = id
        self.coordinate = coordinate
        
        super.init()
    }
    
    
}