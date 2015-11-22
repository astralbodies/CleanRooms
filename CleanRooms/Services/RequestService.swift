//
//  RequestService.swift
//  CleanRooms
//
//  Created by Aaron Douglas on 11/20/15.
//  Copyright © 2015 Razeware LLC. All rights reserved.
//

import Foundation
import CoreData

public class RequestService {
  let managedObjectContext: NSManagedObjectContext
  
  public init(managedObjectContext: NSManagedObjectContext) {
    self.managedObjectContext = managedObjectContext
  }
  
  public func getAllRequests(onlyOpen onlyOpen: Bool = false) -> [Request] {
    let fetchRequest = NSFetchRequest(entityName: "Request")
    
    if onlyOpen {
      fetchRequest.predicate = NSPredicate(format: "completed == %@", true)
    }

    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "requestedAt", ascending: true)]
    
    var results: [AnyObject]
    do {
      try results = managedObjectContext.executeFetchRequest(fetchRequest)
    } catch {
      print("Error when fetching Requests: \(error)")
      return [Request]()
    }
    
    return results as! [Request]
  }
  
  public func getRequestByID(requestID: String) -> Request? {
    let fetchRequest = NSFetchRequest(entityName: "Request")
    fetchRequest.predicate = NSPredicate(format: "requestID == %@", requestID)
    
    var results: [AnyObject]
    do {
      try results = managedObjectContext.executeFetchRequest(fetchRequest)
    } catch {
      print("Error when fetching Request by ID: \(error)")
      return nil
    }
    
    return results.first as? Request
  }
}