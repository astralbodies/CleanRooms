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
  private let cleaningRequestService: CleaningRequestService
  private let cleaningRequestServiceRemote: CleaningRequestServiceRemote

  public init(
    roomService: RoomService,
    roomServiceRemote: RoomServiceRemote,
    cleaningRequestService: CleaningRequestService,
    cleaningRequestServiceRemote: CleaningRequestServiceRemote,
    managedObjectContext: NSManagedObjectContext)
  {
    self.managedObjectContext = managedObjectContext
    self.roomService = roomService
    self.roomServiceRemote = roomServiceRemote
    self.cleaningRequestService = cleaningRequestService
    self.cleaningRequestServiceRemote = cleaningRequestServiceRemote
  }

  public func synchronizeAllData(completion: () -> Void) {
    synchronizeRooms {
      self.synchronizeRequests {
        completion()
      }
    }
  }

  public func synchronizeRooms(completion: () -> Void) {
    roomServiceRemote.fetchAllRooms { remoteRooms in
      self.managedObjectContext.performBlockAndWait {
        var existingRooms = self.roomService.getAllRooms()

        for remoteRoom in remoteRooms {
          var room = self.roomService.getRoomByID(remoteRoom.roomID)
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

        self.saveContext()
        completion()
      }
    }
  }

  public func synchronizeRequests(completion: () -> Void) {
    pushDirtyRequests {
      self.pullUpdatedRequests {
        completion()
      }
    }
  }

  func pushDirtyRequests(completion: () -> Void) {
    let dirtyRequests = cleaningRequestService.getAllDirtyCleaningRequests()
    let remoteCleaningRequests = dirtyRequests.map { cleaningRequest in
      return RemoteCleaningRequest(requestID: cleaningRequest.requestID!, revision: cleaningRequest.revision!, roomID: cleaningRequest.room!.roomID!, requestedAt: cleaningRequest.requestedAt, dueBy: cleaningRequest.dueBy, completed: cleaningRequest.completed?.boolValue, completedBy: cleaningRequest.completedBy, notes: cleaningRequest.notes)
    }

    cleaningRequestServiceRemote.updateRemoteCleaningRequests(remoteCleaningRequests) { revisions in
      self.managedObjectContext.performBlock {
        if let revisions = revisions {
          for revision in revisions {
            let cleaningRequest = dirtyRequests[revisions.indexOf(revision)!]
            cleaningRequest.revision = revision
          }
        }

        self.saveContext()
        completion()
      }
    }
  }

  func pullUpdatedRequests(completion: () -> Void) {
    cleaningRequestServiceRemote.fetchAllRequests { remoteCleaningRequests in
      self.managedObjectContext.performBlockAndWait {
        var existingRequests = self.cleaningRequestService.getAllCleaningRequests()

        for remoteCleaningRequest in remoteCleaningRequests {
          var cleaningRequest = self.cleaningRequestService.getCleaningRequestByID(remoteCleaningRequest.requestID)
          if let cleaningRequest = cleaningRequest {
            if let index = existingRequests.indexOf(cleaningRequest) {
              existingRequests.removeAtIndex(index)
            }
          } else {
            cleaningRequest = NSEntityDescription.insertNewObjectForEntityForName("CleaningRequest", inManagedObjectContext: self.managedObjectContext) as? CleaningRequest
          }

          cleaningRequest!.completed = remoteCleaningRequest.completed
          cleaningRequest!.completedBy = remoteCleaningRequest.completedBy
          cleaningRequest!.requestedAt = remoteCleaningRequest.requestedAt
          cleaningRequest!.dueBy = remoteCleaningRequest.dueBy
          cleaningRequest!.requestID = remoteCleaningRequest.requestID
          cleaningRequest!.revision = remoteCleaningRequest.revision
          cleaningRequest!.room = self.roomService.getRoomByID(remoteCleaningRequest.roomID)
          cleaningRequest!.notes = remoteCleaningRequest.notes
        }

        // Delete requests not in remote API
        for cleaningRequest in existingRequests {
          self.managedObjectContext.deleteObject(cleaningRequest)
        }

        self.saveContext()
        completion()
      }
    }
  }

  private func saveContext() {
    do {
      try self.managedObjectContext.save()
    } catch {
      print("Error while saving context: \(error)")
    }
  }
}
