//
//  SynchronizationService.swift
//  CleanRooms
//
//  Created by Aaron Douglas on 11/22/15.
//  Copyright © 2015 Razeware LLC. All rights reserved.
//

import Foundation
import CoreData

public class SynchronizationService {
  private let managedObjectContext: NSManagedObjectContext
  private let roomService: RoomService
  private let roomServiceRemote: RoomServiceRemote
  private let requestService: RequestService
  private let requestServiceRemote: RequestServiceRemote
  
  public init(
    roomService: RoomService,
    roomServiceRemote: RoomServiceRemote,
    requestService: RequestService,
    requestServiceRemote: RequestServiceRemote,
    managedObjectContext: NSManagedObjectContext)
  {
    self.managedObjectContext = managedObjectContext
    self.roomService = roomService
    self.roomServiceRemote = roomServiceRemote
    self.requestService = requestService
    self.requestServiceRemote = requestServiceRemote
  }
  
  public func synchronizeAllData(completion: () -> Void) {

  }
  
  public func synchronizeRooms(completion: () -> Void) {
    roomServiceRemote.fetchAllRooms { (remoteRooms) -> Void in
      self.managedObjectContext.performBlockAndWait({ () -> Void in
        var existingRooms = self.roomService.getAllRooms()
        
        for remoteRoom in remoteRooms {
          var room = self.roomService.getRoomByID(remoteRoom.roomID!)
          if let room = room {
            print("Existing room.")
            if let index = existingRooms.indexOf(room) {
              existingRooms.removeAtIndex(index)
            }
          } else {
            // New room
            print("New room.")
            room = NSEntityDescription.insertNewObjectForEntityForName("Room", inManagedObjectContext: self.managedObjectContext) as? Room
          }
          
          room!.area = remoteRoom.area
          room!.bathrooms = remoteRoom.bathrooms
          room!.beds = remoteRoom.beds
          room!.revision = remoteRoom.revision
          room!.roomNumber = remoteRoom.roomNumber
          room!.roomID = remoteRoom.roomID
        }
        
        // Delete rooms not in remote API
        for room in existingRooms {
          self.managedObjectContext.deleteObject(room)
        }
        
        do {
          try self.managedObjectContext.save()
        } catch {
          print("Error while saving context: \(error)")
        }
        
        completion()
      })
    }
    
    
  }
  
  public func synchronizeRequests(completion: () -> Void) {
    let existingRequests = requestService.getAllRequests()
  }
}