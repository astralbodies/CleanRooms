//
//  RequestServiceTests.swift
//  CleanRooms
//
//  Created by Aaron Douglas on 11/20/15.
//  Copyright © 2015 Razeware LLC. All rights reserved.
//

import XCTest
import CoreData
import CleanRooms

class RequestServiceTests: XCTestCase {
  var testCoreDataStack: TestCoreDataStack!
  var subject: RequestService!
  
  override func setUp() {
    super.setUp()
    
    testCoreDataStack = TestCoreDataStack()
    subject = RequestService(managedObjectContext: testCoreDataStack.managedObjectContext)
  }
  
  override func tearDown() {
    super.tearDown()
    
    testCoreDataStack = nil
  }
  
  func testGetAllRequestsNoRequests() {
    let results = subject.getAllRequests()
    
    XCTAssertEqual(0, results.count)
  }
  
  func testGetAllRequestsOneRequest() {
    let room = insertRoom()
    insertRequest(room)
    
    let results = subject.getAllRequests()
    
    XCTAssertEqual(1, results.count)
  }
  
  func testGetAllRequestsOnlyOpen() {
    
  }
  
  func insertRoom(roomID: String = NSUUID().UUIDString) -> Room {
    let room = NSEntityDescription.insertNewObjectForEntityForName("Room", inManagedObjectContext: testCoreDataStack.managedObjectContext) as! Room
    room.roomID = roomID
    room.area = 300
    room.bathrooms = 1
    room.beds = 2
    room.roomNumber = "100"
    
    testCoreDataStack.saveContext()
    
    return room
  }
  
  func insertRequest(room: Room) {
    let request = NSEntityDescription.insertNewObjectForEntityForName("Request", inManagedObjectContext: testCoreDataStack.managedObjectContext) as! Request
    request.room = room
    request.requestedAt = NSDate()
    request.requestedBy = NSDate()
    
    testCoreDataStack.saveContext()
  }
  
}
