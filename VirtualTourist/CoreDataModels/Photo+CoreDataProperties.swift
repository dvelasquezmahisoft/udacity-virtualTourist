//
//  Photo+CoreDataProperties.swift
//  
//
//  Created by Daniela Velasquez on 2/25/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Photo {

    @NSManaged var imageUrl: String?
    @NSManaged var name: String?

}
