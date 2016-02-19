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

public class CleaningRequestService {
  let managedObjectContext: NSManagedObjectContext

  public init(managedObjectContext: NSManagedObjectContext) {
    self.managedObjectContext = managedObjectContext
  }

  public func getAllCleaningRequests(onlyOpen onlyOpen: Bool = false) -> [CleaningRequest] {
    let fetchRequest = NSFetchRequest(entityName: "CleaningRequest")

    if onlyOpen {
      fetchRequest.predicate = NSPredicate(format: "completed == %@", true)
    }

    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "requestedAt", ascending: true), NSSortDescriptor(key: "room.roomNumber", ascending: true)]

    var results: [AnyObject]
    do {
      try results = managedObjectContext.executeFetchRequest(fetchRequest)
    } catch {
      print("Error when fetching Requests: \(error)")
      return [CleaningRequest]()
    }

    return results as! [CleaningRequest]
  }

  public func getAllDirtyCleaningRequests() -> [CleaningRequest] {
    let fetchRequest = NSFetchRequest(entityName: "CleaningRequest")
    fetchRequest.predicate = NSPredicate(format: "dirty == %@", true)

    var results: [AnyObject]
    do {
      try results = managedObjectContext.executeFetchRequest(fetchRequest)
    } catch {
      print("Error when fetching dirty Requests: \(error)")
      return [CleaningRequest]()
    }

    return results as! [CleaningRequest]
  }

  public func getCleaningRequestByID(requestID: String) -> CleaningRequest? {
    let fetchRequest = NSFetchRequest(entityName: "CleaningRequest")
    fetchRequest.predicate = NSPredicate(format: "requestID == %@", requestID)

    var results: [AnyObject]
    do {
      try results = managedObjectContext.executeFetchRequest(fetchRequest)
    } catch {
      print("Error when fetching CleaningRequest by ID: \(error)")
      return nil
    }

    return results.first as? CleaningRequest
  }

  public func markCleaningRequestAsCompleted(requestID: String, notes: String?) -> CleaningRequest? {
    let cleaningRequest = getCleaningRequestByID(requestID)
    cleaningRequest?.completed = true
    cleaningRequest?.dirty = true
    cleaningRequest?.notes = notes

    return cleaningRequest
  }
}
