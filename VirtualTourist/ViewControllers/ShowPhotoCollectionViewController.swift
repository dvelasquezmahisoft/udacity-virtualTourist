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

class ShowPhotoCollectionController: BaseViewController {
    
    @IBOutlet weak var mapDetail: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noImagesLbl: UILabel!
    
    //MARK: Logic
    let regionRadius: CLLocationDistance = 300
    var pin: Pin!
    var connectionAPI:ConnectionAPI = ConnectionAPI()
    
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    var lastDowloaded = 0 //manage new collection request
    
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
        
        showRequestMode(show: false)
        noImagesLbl.hidden = true
        
        connectionAPI.delegate = self
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
    
    
    //MARK: IBActions
    @IBAction func addNewCollection(sender: AnyObject) {
        getNewCollection()
    }
    
    @IBAction func goBack(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
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
    
    
    func getFlickrPhotos() {
        
        showRequestMode(show: true)
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
    
    
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        collectionView.performBatchUpdates(nil, completion: nil)
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
    
    func collectionView(collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath) {
            deletePhoto(indexPath)
    }
    
}


extension ShowPhotoCollectionController: NSFetchedResultsControllerDelegate{
    
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

extension ShowPhotoCollectionController: ConnectionAPIProtocol{
    
    func didReceiveSuccess(results results: AnyObject) {
        
        let photosResult = results as! NSArray
        
        for photoProperty in photosResult {
            PersistenceManager.instance.savePhoto(pin, imagePath: photoProperty["remotePath"] as! String, name: photoProperty["imageName"] as! String)
        }
        
        dispatch_async(dispatch_get_main_queue()) {
        
            self.showRequestMode(show: false)
            self.noImagesLbl.hidden = (photosResult.count != 0)
            
            PersistenceManager.instance.saveContext()
        }
    }
    
    
    func didReceiveFail(error error: NSError, errorObject:AnyObject) {
        
        dispatch_async(dispatch_get_main_queue()) {
            self.showRequestMode(show: false)
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

*/