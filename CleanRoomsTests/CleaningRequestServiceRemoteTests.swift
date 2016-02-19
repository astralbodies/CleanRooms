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
import CleanRooms

class RequestServiceRemoteTests: XCTestCase {
  var mockURLSession: MockNSURLSession!
  var subject: CleaningRequestServiceRemote!

  override func setUp() {
    super.setUp()

    mockURLSession = MockNSURLSession()
    subject = CleaningRequestServiceRemote(urlSession: mockURLSession)
  }

  override func tearDown() {
    super.tearDown()
  }

  func testFetchAllRequests() {
    let jsonData = readFile("requests")
    let urlResponse = NSHTTPURLResponse(URL: NSURL(string: "http://localhost:5984/requests/_all_docs?include_docs=true")!, statusCode: 200, HTTPVersion: nil, headerFields: nil)
    MockNSURLSession.mockResponse = (jsonData, urlResponse: urlResponse, error: nil)
    let expectation = self.expectationWithDescription("FetchAllRequests")

    subject.fetchAllRequests { remoteCleaningRequests in
      expectation.fulfill()
      XCTAssertEqual(1, remoteCleaningRequests.count)
    }

    self.waitForExpectationsWithTimeout(2.0, handler: nil)
  }
}
