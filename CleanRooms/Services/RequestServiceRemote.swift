//
//  RequestServiceRemote.swift
//  CleanRooms
//
//  Created by Aaron Douglas on 11/22/15.
//  Copyright © 2015 Razeware LLC. All rights reserved.
//

import Foundation

public class RequestServiceRemote {
  private var urlSession: NSURLSession!
  
  public init() {
    urlSession = NSURLSession.sharedSession()
  }
  
  public init(urlSession: NSURLSession) {
    self.urlSession = urlSession
  }
  
  public func fetchAllRequests(completion: ([RemoteRequest]) -> Void) {
    let url = NSURL(string: "http://localhost:5984/requests/_all_docs?include_docs=true")!
    
    let urlRequest = NSMutableURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0 * 1000)
    urlRequest.HTTPMethod = "GET"
    urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
    
    let task = urlSession.dataTaskWithRequest(urlRequest) { (data, response, error) -> Void in
      guard error == nil else {
        print("Error while fetching remote rooms: \(error)")
        completion([RemoteRequest]())
        return
      }
      
      var json = try? NSJSONSerialization.JSONObjectWithData(data!, options: []) as! [String: AnyObject]
      
      guard json != nil else {
        print("Nil data received from fetchAllRooms")
        completion([RemoteRequest]())
        return
      }
      
      let rows = json!["rows"] as! [[String: AnyObject]]
      var rooms = [RemoteRequest]()
      for roomDict in rows {
        rooms.append(RemoteRequest(jsonData: roomDict))
      }
      
      completion(rooms)
    }
    
    task.resume()
  }
}