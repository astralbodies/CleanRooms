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
