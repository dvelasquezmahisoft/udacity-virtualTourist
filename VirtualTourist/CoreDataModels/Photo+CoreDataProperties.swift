//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Daniela Velasquez on 2/24/16.
//  Copyright © 2016 Mahisoft. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Photo {

    @NSManaged var content: NSData?
    @NSManaged var name: String?

}
