//
//  RemoteRequestTests.swift
//  CleanRooms
//
//  Created by Aaron Douglas on 11/22/15.
//  Copyright © 2015 Razeware LLC. All rights reserved.
//

import XCTest
import CleanRooms
import Foundation

class RemoteRequestTests: XCTestCase {
  var subject: RemoteRequest!
  
  override func setUp() {
    super.setUp()

    subject = RemoteRequest(requestID: "1234", revision: "54321", roomID: "9999", requestedAt: nil, dueBy: nil, completed: false, completedBy: nil)
  }
  
  override func tearDown() {
    super.tearDown()
    
    subject = nil
  }
  
  func testExample() {
    let jsonData = subject.jsonData()
    
    print(NSString(data: jsonData!, encoding: NSUTF8StringEncoding))
    
    XCTAssertNotNil(jsonData)
  }
}
