//
//  Photo+CoreDataProperties.swift
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
import UIKit


extension Photo {

    @NSManaged var imageUrl: String?
    @NSManaged var name: String?
    @NSManaged var pin: Pin?
   
    convenience init(name: String, imageUrl: String, context: NSManagedObjectContext) {
       
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.name = name
        self.imageUrl = imageUrl
    }
    
    
    override func prepareForDeletion() {
        super.prepareForDeletion()
        
        ImageLoader.instance.deleteImage(name!)
    }
}
