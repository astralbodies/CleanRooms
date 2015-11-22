//
//  Request+CoreDataProperties.swift
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

public extension Request {

    @NSManaged var completed: NSNumber?
    @NSManaged var completedBy: String?
    @NSManaged var requestedAt: NSDate?
    @NSManaged var dueBy: NSDate?
    @NSManaged var requestID: String?
    @NSManaged var revision: String?
    @NSManaged var room: Room?

}
