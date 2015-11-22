//
//  MockNSURLSession.swift
//  CleanRooms
//
//  Created by Aaron Douglas on 11/22/15.
//  Copyright © 2015 Razeware LLC. All rights reserved.
//

import Foundation

// Taken from http://swiftandpainless.com/stubbing-nsurlsession-with-dependency-injection/
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