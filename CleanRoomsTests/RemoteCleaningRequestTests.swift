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

class RemoteCleaningRequestTests: XCTestCase {
  var subject: RemoteCleaningRequest!

  override func setUp() {
    super.setUp()

  }

  override func tearDown() {
    super.tearDown()

    subject = nil
  }

  func testRequestID() {
    subject = loadCleaningRequestFromJSON()

    XCTAssertEqual("4da74a0abb4896376622c6eeed0018f4", subject.requestID)
  }

  func testRevision() {
    subject = loadCleaningRequestFromJSON()

    XCTAssertEqual("1-108ce4f3e2f178655c67170e987406b8", subject.revision)
  }

  func testRoomID() {
    subject = loadCleaningRequestFromJSON()

    XCTAssertEqual("b52353e4f1f3dc2cc38f1afd560005fd", subject.roomID)
  }

  func testRequestedAt() {
    subject = loadCleaningRequestFromJSON()

    XCTAssertNotNil(subject.requestedAt)
  }

  func testDueBy() {
    subject = loadCleaningRequestFromJSON()

    XCTAssertNotNil(subject.dueBy)
  }

  func testCompleted() {
    subject = loadCleaningRequestFromJSON()

    XCTAssertFalse(subject.completed!)
  }

  func testCompletedBy() {
    subject = loadCleaningRequestFromJSON()

    XCTAssertNil(subject.completedBy)
  }

  func testNotes() {
    subject = loadCleaningRequestFromJSON()

    XCTAssertEqual("Testing 123", subject.notes)
  }

  func loadCleaningRequestFromJSON() -> RemoteCleaningRequest {
    let data = readFile("requests")
    let json = try? NSJSONSerialization.JSONObjectWithData(data!, options: []) as! [String: AnyObject]
    let rows = json!["rows"] as! [[String: AnyObject]]
    let firstRow = rows.first!

    return RemoteCleaningRequest(jsonData: firstRow)
  }
}
