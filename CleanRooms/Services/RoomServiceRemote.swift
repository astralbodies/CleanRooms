//
//  RoomServiceRemote.swift
//  CleanRooms
//
//  Created by Aaron Douglas on 11/20/15.
//  Copyright © 2015 Razeware LLC. All rights reserved.
//

import Foundation

public class RoomServiceRemote {
  private var urlSession: NSURLSession!
  
  public init() {
    urlSession = NSURLSession.sharedSession()
  }
  
  public init(urlSession: NSURLSession) {
    self.urlSession = urlSession
  }
  
  public func fetchAllRooms(completion: ([RemoteRoom]) -> Void) {
    let url = NSURL(string: "http://localhost:5984/rooms/_all_docs?include_docs=true")!
    
    let urlRequest = NSMutableURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0 * 1000)
    urlRequest.HTTPMethod = "GET"
    urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
    
    let task = urlSession.dataTaskWithRequest(urlRequest) { (data, response, error) -> Void in
      guard error == nil else {
        print("Error while fetching remote rooms: \(error)")
        completion([RemoteRoom]())
        return
      }
      
      var json = try? NSJSONSerialization.JSONObjectWithData(data!, options: []) as! [String: AnyObject]
      
      guard json != nil else {
        print("Nil data received from fetchAllRooms")
        completion([RemoteRoom]())
        return
      }

      let rows = json!["rows"] as! [[String: AnyObject]]
      var rooms = [RemoteRoom]()
      for roomDict in rows {
        rooms.append(RemoteRoom(jsonData: roomDict))
      }
      
      completion(rooms)
    }
    
    task.resume()
  }
}