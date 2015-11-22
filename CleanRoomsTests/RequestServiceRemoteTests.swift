//
//  RequestServiceRemoteTests.swift
//  CleanRooms
//
//  Created by Aaron Douglas on 11/22/15.
//  Copyright © 2015 Razeware LLC. All rights reserved.
//

import XCTest
import CleanRooms

class RequestServiceRemoteTests: XCTestCase {
  var mockURLSession: MockNSURLSession!
  var subject: RequestServiceRemote!
  
  override func setUp() {
    super.setUp()
    
    mockURLSession = MockNSURLSession()
    subject = RequestServiceRemote(urlSession: mockURLSession)
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testFetchAllRequests() {
    let jsonData = readFile("requests")
    let urlResponse = NSHTTPURLResponse(URL: NSURL(string: "http://localhost:5984/requests/_all_docs?include_docs=true")!, statusCode: 200, HTTPVersion: nil, headerFields: nil)
    MockNSURLSession.mockResponse = (jsonData, urlResponse: urlResponse, error: nil)
    let expectation = self.expectationWithDescription("FetchAllRequests")
    
    subject.fetchAllRequests { (requests) -> Void in
      expectation.fulfill()
      XCTAssertEqual(1, requests.count)
    }
    
    self.waitForExpectationsWithTimeout(2.0, handler: nil)
  }
}
