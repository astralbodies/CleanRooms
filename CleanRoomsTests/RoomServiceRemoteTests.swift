//
//  RoomServiceRemoteTests.swift
//  CleanRooms
//
//  Created by Aaron Douglas on 11/22/15.
//  Copyright © 2015 Razeware LLC. All rights reserved.
//

import XCTest
import CleanRooms

class RoomServiceRemoteTests : XCTestCase {
  var mockURLSession: MockNSURLSession!
  var subject: RoomServiceRemote!
  
  override func setUp() {
    super.setUp()
    
    mockURLSession = MockNSURLSession()
    subject = RoomServiceRemote(urlSession: mockURLSession)
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testFetchAllRooms() {
    let jsonData = readFile("rooms")
    let urlResponse = NSHTTPURLResponse(URL: NSURL(string: "http://localhost:5984/rooms/_all_docs?include_docs=true")!, statusCode: 200, HTTPVersion: nil, headerFields: nil)
    MockNSURLSession.mockResponse = (jsonData, urlResponse: urlResponse, error: nil)
    let expectation = self.expectationWithDescription("FetchAllRooms")
    
    subject.fetchAllRooms { (rooms) -> Void in
      expectation.fulfill()
      XCTAssertEqual(2, rooms.count)
    }
    
    self.waitForExpectationsWithTimeout(2.0, handler: nil)
  }
  
  func readFile(filename: String) -> NSData? {
    if let path = NSBundle(forClass: RoomServiceRemoteTests.self).pathForResource(filename, ofType: "json") {
      do {
        let jsonData = try NSData(contentsOfFile: path, options:[.DataReadingMappedIfSafe])
        return jsonData
      } catch {
        print("Error while reading file: \(error)")
      }
    }
    
    return nil
  }
}
