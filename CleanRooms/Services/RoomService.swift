//
//  RoomService.swift
//  CleanRooms
//
//  Created by Aaron Douglas on 11/18/15.
//  Copyright © 2015 Razeware LLC. All rights reserved.
//

import Foundation
import CoreData

class RoomService {
  let managedObjectContext: NSManagedObjectContext
  
  init(managedObjectContext: NSManagedObjectContext) {
    self.managedObjectContext = managedObjectContext
  }
  
  func getAllRooms() -> [Room] {
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
  
  func getRoomByID(roomID: String) -> Room? {
    return nil
  }
}