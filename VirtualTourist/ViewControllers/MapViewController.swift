//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Daniela Velasquez on 2/13/16.
//  Copyright © 2016 Mahisoft. All rights reserved.
//

import UIKit
import MapKit
import CoreData


//TODO: Adding loader when the pin is adding
//TODO: Segue to photos
//TODO: Remember the last map location (save in persistence)
//TODO: Request Pin title (currently set Nuevo!!!)

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager:CLLocationManager!
    var updating:Bool?
    let regionRadius: CLLocationDistance = 1000
    
    //MARK: Life Cycle Methods
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        loadPreviousLocation()
        
        //Init locationManager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "addAnnotation:"))
        
        loadPins()
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    
    //MARK: IBAction Methods
    
    
    
    
    //MARK: Other Methods
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    func loadPreviousLocation(){
        //TODO:
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "showPhotoCollection"){
            //(segue.destinationViewController as! ShowPhotoCollectionViewController).updating = updating
        }
    }
    
    func addNewPin(pin: PinAnnotation){
        
        if(PersistenceManager.instance.savePin(pin.title!, lat: pin.coordinate.latitude, lon: pin.coordinate.longitude) == true){
            loadPins()
            showAlert("Pin \(pin.title!) add successfully ", viewController: self)
        }else{
            showAlert("Could not save pin \(pin.title!)", viewController: self)
        }
        
        //performSegueWithIdentifier("showPhotoCollection", sender: self)
    }
    
    
    /**
     * Tap Gesture Recognizer action.
     * Adding a pinAnnotation in the map and save info in persistence.
     * @param: gestureRecognizer (TapGestureRecognizer)
     */
    func addAnnotation(gestureRecognizer:UIGestureRecognizer){
    
        let touchPoint = gestureRecognizer.locationInView(mapView)
        let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        
        let annotation = PinAnnotation(title: "Nuevo!!!", coordinate: newCoordinates)
        
        
        //TODO: Show loader
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: newCoordinates.latitude,
            longitude: newCoordinates.longitude),
            completionHandler: {(placemarks, error) -> Void in
                
                //TODO: Hide loader
                if error != nil {
                    showAlert("Reverse geocoder failed with error" + error!.localizedDescription, viewController: self)
                    return
                }
                
                self.mapView.addAnnotation(annotation)
                
                self.addNewPin(annotation)
                
        })
        
    }
    
    /**
     * Load persistence pins.
     */
    func loadPins(){
        
        let pins = PersistenceManager.instance.getLocationPins()
        
        guard pins.count > 0 else{
            showAlert(Messages.mNoPins, viewController: self)
            return
        }
        
        for sLocation in pins{
            
            let lat = sLocation.valueForKey("lat") as! NSNumber
            let lon = sLocation.valueForKey("lon") as! NSNumber
            
            let annotation = PinAnnotation(title: sLocation.valueForKey("name") as! String,
                coordinate:  CLLocationCoordinate2D(latitude: lat.doubleValue, longitude: lon.doubleValue))
            
            //Add pin annotation in the map
            mapView.addAnnotation(annotation)
        }
    }
    
    
    
}


extension MapViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let annotation = annotation as? PinAnnotation {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView {
                    dequeuedView.annotation = annotation
                    view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            }
            return view
        }
        
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl){
        
        let pin = view.annotation as! PinAnnotation
        
        addNewPin(pin)
        
    }
}

extension MapViewController: CLLocationManagerDelegate{
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0]
        centerMapOnLocation(userLocation)
    }
    
}

