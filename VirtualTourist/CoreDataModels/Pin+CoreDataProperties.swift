//
//  Pin+CoreDataProperties.swift
//  
//
//  Created by Daniela Velasquez on 2/27/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData
import MapKit

extension Pin {

    @NSManaged var identifier: NSNumber?
    @NSManaged var lat: NSNumber?
    @NSManaged var lon: NSNumber?
    @NSManaged var photos: [Photo]

    
    
    var coordinate: CLLocationCoordinate2D {
        get {
            let coordinate = CLLocationCoordinate2DMake(Double(lat!) as CLLocationDegrees, Double(lon!) as CLLocationDegrees)
            return coordinate
        }
        set {
            lat = newValue.latitude
            lon = newValue.longitude
        }
    }
}
