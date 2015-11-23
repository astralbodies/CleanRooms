/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

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
    synchronizeRooms { () -> Void in
      self.synchronizeRequests({ () -> Void in
        completion()
      })
    }
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
          room!.roomID = remoteRoom.roomID!
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
    pushDirtyRequests { () -> Void in
      self.pullUpdatedRequests({ () -> Void in
        completion()
      })
    }
  }
  
  func pushDirtyRequests(completion: () -> Void) {
    let dirtyRequests = requestService.getAllDirtyRequests()
    let remoteRequests = dirtyRequests.map { (request) -> RemoteRequest in
      return RemoteRequest(requestID: request.requestID!, revision: request.revision!, roomID: request.room!.roomID, requestedAt: request.requestedAt, dueBy: request.dueBy, completed: request.completed?.boolValue, completedBy: request.completedBy, notes: request.notes)
    }
    
    requestServiceRemote.updateRemoteRequests(remoteRequests) { (revisions) -> Void in
      self.managedObjectContext.performBlock({ () -> Void in
        if let revisions = revisions {
          for revision in revisions {
            let request = dirtyRequests[revisions.indexOf(revision)!]
            request.revision = revision
          }
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
  
  func pullUpdatedRequests(completion: () -> Void) {
    requestServiceRemote.fetchAllRequests { (remoteRequests) -> Void in
      self.managedObjectContext.performBlockAndWait({ () -> Void in
        var existingRequests = self.requestService.getAllRequests()
        
        for remoteRequest in remoteRequests {
          var request = self.requestService.getRequestByID(remoteRequest.requestID)
          if let request = request {
            if let index = existingRequests.indexOf(request) {
              existingRequests.removeAtIndex(index)
            }
          } else {
            request = NSEntityDescription.insertNewObjectForEntityForName("Request", inManagedObjectContext: self.managedObjectContext) as? Request
          }
          
          request!.completed = remoteRequest.completed
          request!.completedBy = remoteRequest.completedBy
          request!.requestedAt = remoteRequest.requestedAt
          request!.dueBy = remoteRequest.dueBy
          request!.requestID = remoteRequest.requestID
          request!.revision = remoteRequest.revision
          request!.room = self.roomService.getRoomByID(remoteRequest.roomID)
        }
        
        // Delete requests not in remote API
        for request in existingRequests {
          self.managedObjectContext.deleteObject(request)
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
}