//
//  PersistenceManager.swift
//  VirtualTourist
//
//  Created by Daniela Velasquez on 2/22/16.
//  Copyright © 2016 Mahisoft. All rights reserved.
//

import UIKit
import CoreData
import MapKit


//TODO: Photo adding function
//TODO: Photo consult function

class PersistenceManager: NSObject {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    class var instance: PersistenceManager {
        
        struct Static {
            static var instance: PersistenceManager?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = PersistenceManager()
        }
        
        return Static.instance!
    }
    
    required override init(){
        
    }
    
 
    func saveCurrentZoom(zoom:MKCoordinateSpan){
        NSUserDefaults.standardUserDefaults().setDouble(zoom.latitudeDelta, forKey: "userZoomLat")
        NSUserDefaults.standardUserDefaults().setDouble(zoom.longitudeDelta, forKey: "userZoomLon")
    }
    
    func getCurrentZoom()-> MKCoordinateSpan{

        let lat = NSUserDefaults.standardUserDefaults().doubleForKey("userZoomLat")
        let lon = NSUserDefaults.standardUserDefaults().doubleForKey("userZoomLon")
        
        let coord = MKCoordinateSpanMake(lat, lon)
        
        return coord
    }
    
    func saveCurrentLocation(lat:Double, lon:Double){
        NSUserDefaults.standardUserDefaults().setDouble(lat, forKey: "userLat")
        NSUserDefaults.standardUserDefaults().setDouble(lon, forKey: "userLon")
    }
    
    func getCurrentLocation()-> CLLocationCoordinate2D{
        
        let lat = NSUserDefaults.standardUserDefaults().doubleForKey("userLat")
        let lon = NSUserDefaults.standardUserDefaults().doubleForKey("userLon")
        
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        
        return coord
    }
    
    func getLocationPins() -> [Pin]{
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        do {
            
            let results = try managedContext.executeFetchRequest(fetchRequest)
            
            return results as! [Pin]
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            return [Pin]()
        }
        
    }
    
    func getPhotosPin(pin: Pin) -> [Photo]{
        
        //TODO: Use the pin information
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        
        do {
            
            let results = try managedContext.executeFetchRequest(fetchRequest)
            return results as! [Photo]
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            return [Photo]()
        }
        
    }
    
    
    //MARK: Save Methods
    
    func savePin(name: String, lat: NSNumber, lon: NSNumber) -> Bool{
        
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext:managedContext)
        
        let pin = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        pin.setValue(name, forKey: "name")
        pin.setValue(lat, forKey: "lat")
        pin.setValue(lon, forKey: "lon")
        
        do {
            try managedContext.save()
            return true
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
            return false
        }
    }
}
