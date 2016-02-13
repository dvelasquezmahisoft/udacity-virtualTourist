//
//  ShowPhotoCollectionViewController.swift
//  VirtualTourist
//
//  Created by Daniela Velasquez on 2/13/16.
//  Copyright © 2016 Mahisoft. All rights reserved.
//

import UIKit
import MapKit


class ShowPhotoCollectionViewController: UIViewController {

    @IBOutlet weak var mapDetail: MKMapView!
    @IBOutlet weak var photoCollection: UICollectionView!
    @IBOutlet weak var newCollectionBtn: UIButton!
    
    //MARK: Logic Vars
    var pinLocation:PinLocation?
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
        
        //showRequestMode(show: false)
        
    }
    
    
    
    @IBAction func addNewCollection(sender: AnyObject) {
    
    
    }
    
    
    //MARK: Other Methods
    func loadPinLocation(){
        
        //Show pin in the map
        let annotation = PinAnnotation(title: (pinLocation?.firstName)!, url: "", coordinate:  CLLocationCoordinate2D(latitude:  pinLocation!.latitude, longitude:  pinLocation!.longitude))
        
        mapDetail.addAnnotation(annotation)
    }
    
}
