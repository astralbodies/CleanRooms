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

import Foundation

// Based off of http://swiftandpainless.com/stubbing-nsurlsession-with-dependency-injection/
class MockNSURLSession: NSURLSession {
  var completionHandler: ((NSData!, NSURLResponse!, NSError!) -> Void)?

  static var mockResponse: (data: NSData?, urlResponse: NSURLResponse?, error: NSError?) = (data: nil, urlResponse: nil, error: nil)

  override class func sharedSession() -> NSURLSession {
    return MockNSURLSession()
  }

  override func dataTaskWithRequest(request: NSURLRequest, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> NSURLSessionDataTask {
    self.completionHandler = completionHandler
    return MockTask(response: MockNSURLSession.mockResponse, completionHandler: completionHandler)
  }

  override func dataTaskWithURL(url: NSURL, completionHandler: ((NSData!, NSURLResponse!, NSError!) -> Void)?) -> NSURLSessionDataTask {
    self.completionHandler = completionHandler
    return MockTask(response: MockNSURLSession.mockResponse, completionHandler: completionHandler)
  }

  class MockTask: NSURLSessionDataTask {
    typealias Response = (data: NSData?, urlResponse: NSURLResponse?, error: NSError?)
    var mockResponse: Response
    let completionHandler: ((NSData!, NSURLResponse!, NSError!) -> Void)?

    init(response: Response, completionHandler: ((NSData!, NSURLResponse!, NSError!) -> Void)?) {
      self.mockResponse = response
      self.completionHandler = completionHandler
    }
    override func resume() {
      completionHandler!(mockResponse.data, mockResponse.urlResponse, mockResponse.error)
    }
  }
}
