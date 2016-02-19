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

class CleaningRequestServiceTests: XCTestCase {
  var testCoreDataStack: TestCoreDataStack!
  var subject: CleaningRequestService!

  override func setUp() {
    super.setUp()

    testCoreDataStack = TestCoreDataStack()
    subject = CleaningRequestService(managedObjectContext: testCoreDataStack.managedObjectContext)
  }

  override func tearDown() {
    super.tearDown()

    testCoreDataStack = nil
  }

  func testGetAllRequestsNoRequests() {
    let results = subject.getAllCleaningRequests()

    XCTAssertEqual(0, results.count)
  }

  func testGetAllRequestsOneRequest() {
    let room = insertRoom()
    insertRequest(room)

    let results = subject.getAllCleaningRequests()

    XCTAssertEqual(1, results.count)
  }

  func testGetAllRequestsOnlyOpen() {
    let room = insertRoom()
    insertRequest(room, completed: false)
    insertRequest(room, completed: true)

    let results = subject.getAllCleaningRequests(onlyOpen: true)

    XCTAssertEqual(1, results.count)
  }

  func testGetRequestByIDNoMatch() {
    let cleaningRequest = subject.getCleaningRequestByID("123")

    XCTAssertNil(cleaningRequest)
  }

  func testGetRequestByIDMatch() {
    let room = insertRoom()
    insertRequest(room, requestID: "123", completed: false)

    let cleaningRequest = subject.getCleaningRequestByID("123")

    XCTAssertNotNil(cleaningRequest)
  }
}

// MARK: Helper methods
extension CleaningRequestServiceTests {
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

  func insertRequest(room: Room, requestID: String = "test", completed: Bool = false) {
    let cleaningRequest = NSEntityDescription.insertNewObjectForEntityForName("CleaningRequest", inManagedObjectContext: testCoreDataStack.managedObjectContext) as! CleaningRequest
    cleaningRequest.room = room
    cleaningRequest.requestedAt = NSDate()
    cleaningRequest.dueBy = NSDate()
    cleaningRequest.completed = completed
    cleaningRequest.requestID = requestID

    testCoreDataStack.saveContext()
  }

}
