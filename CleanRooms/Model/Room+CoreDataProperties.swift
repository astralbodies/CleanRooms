//
//  Room+CoreDataProperties.swift
//  CleanRooms
//
//  Created by Aaron Douglas on 11/22/15.
//  Copyright © 2015 Razeware LLC. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

public extension Room {

    @NSManaged var area: NSNumber?
    @NSManaged var bathrooms: NSNumber?
    @NSManaged var beds: NSNumber?
    @NSManaged var roomID: String
    @NSManaged var roomNumber: String?
    @NSManaged var revision: String?
    @NSManaged var requests: NSSet?

}
