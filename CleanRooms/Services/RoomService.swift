//
//  RoomService.swift
//  CleanRooms
//
//  Created by Aaron Douglas on 11/18/15.
//  Copyright © 2015 Razeware LLC. All rights reserved.
//

import Foundation
import CoreData

public class RoomService {
  let managedObjectContext: NSManagedObjectContext
  
  public init(managedObjectContext: NSManagedObjectContext) {
    self.managedObjectContext = managedObjectContext
  }
  
  public func getAllRooms() -> [Room] {
    let fetchRequest = NSFetchRequest(entityName: "Room")
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "roomNumber", ascending: true)]
    
    var results: [AnyObject]
    do {
      try results = managedObjectContext.executeFetchRequest(fetchRequest)
    } catch {
      print("Error when fetching rooms: \(error)")
      return [Room]()
    }
    
    return results as! [Room]
  }
  
  public func getRoomByID(roomID: String) -> Room? {
    let fetchRequest = NSFetchRequest(entityName: "Room")
    fetchRequest.predicate = NSPredicate(format: "roomID == %@", roomID)
    
    var results: [AnyObject]
    do {
      try results = managedObjectContext.executeFetchRequest(fetchRequest)
    } catch {
      print("Error when fetching Room by ID: \(error)")
      return nil
    }
    
    return results.first as? Room
  }
}