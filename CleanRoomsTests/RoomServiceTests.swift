//
//  RoomServiceTests.swift
//  CleanRooms
//
//  Created by Aaron Douglas on 11/20/15.
//  Copyright © 2015 Razeware LLC. All rights reserved.
//

import XCTest
import CoreData
import CleanRooms

class RoomServiceTests: XCTestCase {
  var testCoreDataStack: TestCoreDataStack!
  var subject: RoomService!
  
  override func setUp() {
    super.setUp()

    testCoreDataStack = TestCoreDataStack()
    subject = RoomService(managedObjectContext: testCoreDataStack.managedObjectContext)
  }
  
  override func tearDown() {
    super.tearDown()
    
    testCoreDataStack = nil
  }
  
  func testGetAllRoomsNoRooms() {
    let result = subject.getAllRooms()
    
    XCTAssertEqual(0, result.count)
  }
  
  func testGetAllRoomsOneRoom() {
    insertRoom()
    
    let result = subject.getAllRooms()
    
    XCTAssertNotNil(result)
    XCTAssertEqual(1, result.count)
  }
  
  func testGetRoomByIDNoMatch() {
    insertRoom()
    
    let result = subject.getRoomByID("NoSuchRoom")
    
    XCTAssertNil(result)
  }
  
  func testGetRoomByIDMatch() {
    let roomID = "123"
    insertRoom(roomID)
    
    let result = subject.getRoomByID(roomID)
    
    XCTAssertNotNil(result)
    XCTAssertEqual(roomID, result?.roomID)
  }
  
  func insertRoom(roomID: String = NSUUID().UUIDString) {
    let room = NSEntityDescription.insertNewObjectForEntityForName("Room", inManagedObjectContext: testCoreDataStack.managedObjectContext) as! Room
    room.roomID = roomID
    room.area = 300
    room.bathrooms = 1
    room.beds = 2
    room.roomNumber = "100"
    
    testCoreDataStack.saveContext()
  }
  
}
