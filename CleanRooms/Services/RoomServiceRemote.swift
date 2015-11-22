//
//  RoomServiceRemote.swift
//  CleanRooms
//
//  Created by Aaron Douglas on 11/20/15.
//  Copyright © 2015 Razeware LLC. All rights reserved.
//

import Foundation

public class RoomServiceRemote {
  public func fetchAllRooms(completion: ([RemoteRoom]) -> Void) {
    let url = NSURL(string: "http://localhost:5984/rooms/_all_docs")!
    let urlRequest = NSMutableURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0 * 1000)
    urlRequest.HTTPMethod = "GET"
    urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
    
    let urlSession = NSURLSession.sharedSession()
    let task = urlSession.dataTaskWithRequest(urlRequest) { (data, response, error) -> Void in
      var json: AnyObject
      
      do {
        try json = NSJSONSerialization.JSONObjectWithData(data!, options: [])
      } catch {
        print("Error while fetching all rooms: \(error)")
      }
      
      completion([RemoteRoom]())
    }
    
    task.resume()
  }
}