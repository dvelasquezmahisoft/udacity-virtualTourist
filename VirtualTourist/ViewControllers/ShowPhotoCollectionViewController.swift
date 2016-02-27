//
//  ShowPhotophotoCollectionController.swift
//  VirtualTourist
//
//  Created by Daniela Velasquez on 2/13/16.
//  Copyright © 2016 Mahisoft. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ShowPhotoCollectionController: BaseViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noImagesLbl: UILabel!
    
    //MARK: Logic Vars
    let regionRadius: CLLocationDistance = 300
    var pin: Pin!
    var connectionAPI:ConnectionAPI = ConnectionAPI()
    
    // Cell layout properties
    let cellsPerRowInPortraitMode: CGFloat = 3
    let cellsPerRowInLandscpaeMode: CGFloat = 6
    let minimumSpacingPerCell: CGFloat = 5

    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    var numberOfPhotoCurrentlyDownloading = 0
    
    var persistenceContext: NSManagedObjectContext {
        return  PersistenceManager.instance.managedContext
    }
    
    
    lazy var fetchedController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.persistenceContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        return fetchedResultsController
    }()
    
    
    // MARK: - View Life cycle
    override func viewDidLoad() {
        
        connectionAPI.delegate = self
        noImagesLbl.hidden = true
        
        // CoreData
        fetchedController.delegate = self
        do {
            try fetchedController.performFetch()
        } catch {
            NSLog("Fetch failed: \(error)")
        }
        
        if pin.photos.isEmpty {
            getFlickrPhotos()
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        loadPinLocation()
        
    }
    
    
    func loadPinLocation(){
        
        //Show pin in the map
        let annotation = PinAnnotation(id: Int(pin.identifier!), coordinate:  CLLocationCoordinate2D(latitude:  Double(pin.lat!), longitude:  Double(pin.lon!)))
        
        mapView.addAnnotation(annotation)
        
        //Set initial location
        let initialLocation = CLLocation(latitude: Double(pin.lat!), longitude: Double(pin.lon!))
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    //MARK: IBActions
    @IBAction func addNewCollection(sender: AnyObject) {
        getNewCollection()
    }
    
    @IBAction func goBack(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    // MARK: - Photos
    func getFlickrPhotos() {
        activityIndicator.startAnimating()
        noImagesLbl.hidden = true
        
        FlickrManagement.sharedInstance().photosSearch(pin, connection: connectionAPI)
        
    }
    
    func getNewCollection() {
        
        if let fetchedObjects = fetchedController.fetchedObjects {
            for object in fetchedObjects {
                let photo = object as! Photo
                persistenceContext.deleteObject(photo)
            }
            PersistenceManager.instance.saveContext()
        }
        
        getFlickrPhotos()
    }
    
    
    func deletePhoto(indexPath:NSIndexPath) {
        
        let selectedPhoto = fetchedController.objectAtIndexPath(indexPath) as! Photo
        
        persistenceContext.deleteObject(selectedPhoto)
        
        PersistenceManager.instance.saveContext()
    }
    
    // MARK: - CollectionView layout
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = minimumSpacingPerCell
        layout.minimumInteritemSpacing = minimumSpacingPerCell
        
        var width: CGFloat!
        if UIApplication.sharedApplication().statusBarOrientation.isLandscape == true {
            width = (CGFloat(collectionView.frame.size.width) / cellsPerRowInLandscpaeMode) - (minimumSpacingPerCell - (minimumSpacingPerCell / cellsPerRowInLandscpaeMode))
        } else {
            width = (CGFloat(collectionView.frame.size.width) / cellsPerRowInPortraitMode) - (minimumSpacingPerCell - (minimumSpacingPerCell / cellsPerRowInPortraitMode))
        }
        
        layout.itemSize = CGSize(width: width, height: width)
        
        collectionView.collectionViewLayout = layout
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        collectionView.performBatchUpdates(nil, completion: nil)
    }
    
    
    
    
    // MARK: - NSFetchedResultsController delegates
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
        
        self.activityIndicator.stopAnimating()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            insertedIndexPaths.append(newIndexPath!)
        case .Delete:
            deletedIndexPaths.append(indexPath!)
        case .Update:
            updatedIndexPaths.append(indexPath!)
        default:
            return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionView.performBatchUpdates({
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItemsAtIndexPaths([indexPath])
            }
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItemsAtIndexPaths([indexPath])
            }
            }, completion: nil)
    }
}

extension ShowPhotoCollectionController: UICollectionViewDataSource, UICollectionViewDelegate{
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
            
            return self.fetchedController.sections![section].numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PhotoCollectionCell.identifier, forIndexPath: indexPath) as! PhotoCollectionCell
        
        let photo = fetchedController.objectAtIndexPath(indexPath) as! Photo
        
        //Set cell with meme values
        cell.setup(photo.imageUrl!)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        deletePhoto(indexPath)
    }
    
    
    
    
}


extension ShowPhotoCollectionController: ConnectionAPIProtocol{
    
    func didReceiveSuccess(results results: AnyObject) {
        
        let photosResult = results as! NSArray
        
        for photoProperty in photosResult {
            PersistenceManager.instance.savePhoto(self.pin, imagePath: photoProperty["remotePath"] as! String, name: photoProperty["imageName"] as! String)
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            PersistenceManager.instance.saveContext()
        }
    }
    
    
    func didReceiveFail(error error: NSError, errorObject:AnyObject) {
        
        dispatch_async(dispatch_get_main_queue()) {
            self.activityIndicator.stopAnimating()
            self.noImagesLbl.hidden = false
        }
    }
    
}


/*
class ShowPhotoCollectionController: UIViewController{

@IBOutlet weak var mapDetail: MKMapView!
@IBOutlet weak var photoCollection: UICollectionView!
@IBOutlet weak var newCollectionBtn: UIButton!
@IBOutlet weak var overlay: UIView!
@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
@IBOutlet weak var noImagesLbl: UILabel!

//MARK: Logic Vars
let regionRadius: CLLocationDistance = 300

var pin:Pin!

var photos:[String]?
var photoObjects:[Photo] = [Photo]()

var connectionAPI:ConnectionAPI = ConnectionAPI()

//FetchController aux
var insertedIndexPaths: [NSIndexPath]!
var deletedIndexPaths: [NSIndexPath]!
var updatedIndexPaths: [NSIndexPath]!


var persistenceContext: NSManagedObjectContext {
return PersistenceManager.instance.managedContext
}

lazy var fetchedController: NSFetchedResultsController = {

let fetchRequest = NSFetchRequest(entityName: "Photo")

fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin)
fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

let fetchedController = NSFetchedResultsController(fetchRequest: fetchRequest,

managedObjectContext: self.persistenceContext,
sectionNameKeyPath: nil,
cacheName: nil)

return fetchedController
}()


//MARK: Life Cycle Methods
override func viewDidLoad() {

super.viewDidLoad()

showRequestMode(false)

fetchedController.delegate = self

do {
try fetchedController.performFetch()
} catch {
NSLog("fetchedController error: \(error)")
}


loadPinImages()

connectionAPI.delegate = self

}

override func viewWillAppear(animated: Bool) {


loadPinLocation()

}



//MARK: IBActions

@IBAction func addNewCollection(sender: AnyObject) {
getNewCollection()
}


//MARK: Other Methods
func loadPinLocation(){

//Show pin in the map
let annotation = PinAnnotation(id: Int(pin.identifier!), coordinate:  CLLocationCoordinate2D(latitude:  Double(pin.lat!), longitude:  Double(pin.lon!)))

mapDetail.addAnnotation(annotation)

//Set initial location
let initialLocation = CLLocation(latitude: Double(pin.lat!), longitude: Double(pin.lon!))

let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation.coordinate,
regionRadius * 2.0, regionRadius * 2.0)

mapDetail.setRegion(coordinateRegion, animated: true)

}

func loadPinImages(){

if pin.photos.isEmpty {
getFlickrPhotos()
}
/*
pin = PersistenceManager.instance.getPin(pin.identifier!)

let photoSet = pin.photos?.allObjects

if(photoSet!.count == 0){
getFlickrPhotos()
return
}


for photo in photoSet!{
photoObjects.append((photo as! Photo))
}
*/
// self.photoCollection.reloadData()


}

@IBAction func goBack(sender: AnyObject) {
dismissViewControllerAnimated(true, completion: nil)
}


func showRequestMode(show: Bool){

if(show){
activityIndicator.startAnimating()
}else{
activityIndicator.stopAnimating()
}

activityIndicator.hidden = !show
overlay.hidden = !show
}



// MARK: - Photos
func getFlickrPhotos() {

showRequestMode(true)
self.noImagesLbl.hidden = true

FlickrManagement.sharedInstance().photosSearch(pin, connection: connectionAPI)
}

func getNewCollection() {

if let fetchedObjects = fetchedController.fetchedObjects {

for object in fetchedObjects {
let photo = object as! Photo
persistenceContext.deleteObject(photo)
}

PersistenceManager.instance.saveContext()
}

getFlickrPhotos()
}

func deletePhoto(indexPath:NSIndexPath) {

let selectedPhoto = fetchedController.objectAtIndexPath(indexPath) as! Photo

persistenceContext.deleteObject(selectedPhoto)

PersistenceManager.instance.saveContext()
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


extension ShowPhotoCollectionController: NSFetchedResultsControllerDelegate{

func controllerWillChangeContent(controller: NSFetchedResultsController) {

insertedIndexPaths = [NSIndexPath]()
deletedIndexPaths = [NSIndexPath]()
updatedIndexPaths = [NSIndexPath]()

showRequestMode(false)
}

func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {

switch type {
case .Insert:
insertedIndexPaths.append(newIndexPath!)
case .Delete:
deletedIndexPaths.append(indexPath!)
case .Update:
updatedIndexPaths.append(indexPath!)
default:
return
}
}

func controllerDidChangeContent(controller: NSFetchedResultsController) {



photoCollection.performBatchUpdates({

for indexPath in self.insertedIndexPaths {
self.photoCollection.insertItemsAtIndexPaths([indexPath])
}
for indexPath in self.deletedIndexPaths {
self.photoCollection.deleteItemsAtIndexPaths([indexPath])
}
for indexPath in self.updatedIndexPaths {
self.photoCollection.reloadItemsAtIndexPaths([indexPath])
}
}, completion: nil)

}


}


extension ShowPhotoCollectionController: UICollectionViewDataSource, UICollectionViewDelegate{



func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {

return true
}

func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {

return true
}

func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
//Delete the selected photo
deletePhoto(indexPath)
}


func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {

}



func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
return 1
}

// MARK: Collection View Data Source

func collectionView(photoCollection: UICollectionView, numberOfItemsInSection section: Int) -> Int {
return self.fetchedController.sections![section].numberOfObjects
}

func collectionView(photoCollection: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

let cell = photoCollection.dequeueReusableCellWithReuseIdentifier(PhotoCollectionCell.identifier, forIndexPath: indexPath) as! PhotoCollectionCell

let photo = fetchedController.objectAtIndexPath(indexPath) as! Photo

// let photo = photoObjects[indexPath.row]

//Set cell with meme values
cell.setup(photo.imageUrl!)

return cell
}

}
*/