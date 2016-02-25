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
    @IBOutlet weak var overlay: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noImagesLbl: UILabel!
    
    //MARK: Logic Vars
    var pinLocation:PinLocation?
    var photos:[String]?
    var photoObjects:[Photo] = [Photo]()
    let regionRadius: CLLocationDistance = 300
    var connectionAPI:ConnectionAPI = ConnectionAPI()
    
    func showRequestMode(show: Bool){
        
        if(show){
            activityIndicator.startAnimating()
        }else{
            activityIndicator.stopAnimating()
        }
        
        activityIndicator.hidden = !show
        overlay.hidden = !show
    }
    
    //MARK: Life Cycle Methods
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        
        showRequestMode(false)
        
        //Set initial location
        let initialLocation = CLLocation(latitude: (pinLocation?.latitude)!, longitude: (pinLocation?.longitude)!)
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        
        mapDetail.setRegion(coordinateRegion, animated: true)
        
        loadPinLocation()
        
        loadPinImages()
        
        photoCollection?.reloadData()
        
        self.connectionAPI.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        
    }
    
    // MARK: Collection View Data Source
    func collectionView(photoCollection: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoObjects.count
    }
    
    func collectionView(photoCollection: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = photoCollection.dequeueReusableCellWithReuseIdentifier(PhotoCollectionCell.identifier, forIndexPath: indexPath) as! PhotoCollectionCell
        
        let photo = photoObjects[indexPath.row]
        
        //Set cell with meme values
        cell.setup(photo.imageUrl!)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        
        
    }
    
    
    
    //MARK: IBActions
    
    @IBAction func addNewCollection(sender: AnyObject) {
        getFlickrPhotos()
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
        
        let photoSet = pin.photos?.allObjects
        
        if(photoSet!.count == 0){
            getFlickrPhotos()
            return
        }
        
        
        for photo in photoSet!{
            photoObjects.append((photo as! Photo))
        }
        
        self.photoCollection.reloadData()
        
        
    }
    
    @IBAction func goBack(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - Photos
    
    private func getFlickrPhotos() {
        
        showRequestMode(true)
        self.noImagesLbl.hidden = true
        
        FlickrManagement.sharedInstance().photosSearch(pinLocation!, connection: connectionAPI)
    }
    
    
    
    
}


extension ShowPhotoCollectionController: ConnectionAPIProtocol{
    
    func didReceiveSuccess(results results: AnyObject) {
        
        let photosResult = results as! NSArray
        
        showRequestMode(false)
        noImagesLbl.hidden = (photosResult.count != 0)
        
        
        for photo in photosResult {
            
            PersistenceManager.instance.savePhoto(self.pinLocation!.id!, imagePath: photo["remotePath"] as! String)
        
            //photo.pin = self.pinLocation
        }
        
        // dispatch_async(dispatch_get_main_queue()) {
        //   CoreDataStackManager.sharedInstance.saveContext()
        //}
        
        let pin = PersistenceManager.instance.getPin(self.pinLocation!.id!)
        let photoSet = pin.photos?.allObjects
        
        for photo in photoSet!{
            self.photoObjects.append((photo as! Photo))
        }
        
        
        self.photoCollection.reloadData()
    }
    
    func didReceiveFail(error error: NSError, errorObject:AnyObject) {
        
        showRequestMode(true)
        noImagesLbl.hidden = false
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
