//
//  ShowPhotophotoCollectionController.swift
//  VirtualTourist
//
//  Created by Daniela Velasquez on 2/13/16.
//  Copyright © 2016 Mahisoft. All rights reserved.
//

import UIKit
import MapKit


class ShowPhotoCollectionController: UIViewController {
    
    @IBOutlet weak var mapDetail: MKMapView!
    @IBOutlet weak var photoCollection: UICollectionView!
    @IBOutlet weak var newCollectionBtn: UIButton!
    
    //MARK: Logic Vars
    var pinLocation:PinLocation?
    var photos:[String]?
    var photoObjects:[Photo]?
    let regionRadius: CLLocationDistance = 300
    
    
    //MARK: Life Cycle Methods
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Set initial location
        let initialLocation = CLLocation(latitude: (pinLocation?.latitude)!, longitude: (pinLocation?.longitude)!)
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        
        mapDetail.setRegion(coordinateRegion, animated: true)
        
        loadPinLocation()
        
        loadPinImages()
        
        //showRequestMode(show: false)
        
        photoCollection?.reloadData()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        
    }
    
    // MARK: Collection View Data Source
    func collectionView(photoCollection: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos!.count
    }
    
    func collectionView(photoCollection: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = photoCollection.dequeueReusableCellWithReuseIdentifier(PhotoCollectionCell.identifier, forIndexPath: indexPath) as! PhotoCollectionCell
        
        //Set cell with meme values
        cell.setup()
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        
        
    }
    
    
    
    //MARK: IBActions
    
    @IBAction func addNewCollection(sender: AnyObject) {
        //TODO: Add new photo from location
        let pin = PersistenceManager.instance.getPin(pinLocation!.id!)
    }
    
    
    //MARK: Other Methods
    func loadPinLocation(){
        
        //Show pin in the map
        let annotation = PinAnnotation(id: pinLocation!.id, coordinate:  CLLocationCoordinate2D(latitude:  pinLocation!.latitude, longitude:  pinLocation!.longitude))
        
        mapDetail.addAnnotation(annotation)
        
        //Set initial location
        let initialLocation = CLLocation(latitude: pinLocation!.latitude, longitude: pinLocation!.longitude)
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        
        mapDetail.setRegion(coordinateRegion, animated: true)
        
    }
    
    func loadPinImages(){
    
       let pin = PersistenceManager.instance.getPin(pinLocation!.id!)
        
       print(pin.photos)
       
       let photoSet = pin.photos
    
        if(photoSet!.count == 0){
            print("Sin photos")
            //TODO: Traer las imagenes del otro lado
        }
        
        for photo in photoSet!{
            photoObjects?.append(photo as! Photo)
        }
        
        
    }

    @IBAction func goBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}



extension ShowPhotoCollectionController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? PinAnnotation {
            
            let identifier = "pin"
            var view: MKPinAnnotationView
            
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView {
                    dequeuedView.annotation = annotation
                    view = dequeuedView
            }else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = false
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = nil
            }
            
            return view
        }
        
        return nil
    }
}
