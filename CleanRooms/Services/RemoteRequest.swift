//
//  RemoteRequest.swift
//  CleanRooms
//
//  Created by Aaron Douglas on 11/22/15.
//  Copyright © 2015 Razeware LLC. All rights reserved.
//

import Foundation

import Foundation

public struct RemoteRequest {
  public var requestID: String?
  public var revision: String?
  public var roomID: String?
  public var requestedAt: NSDate?
  public var dueBy: NSDate?
  public var completed: Bool?
  public var completedBy: String?
  
  /* Example data:
        {
            "id": "4da74a0abb4896376622c6eeed0018f4",
            "key": "4da74a0abb4896376622c6eeed0018f4",
            "value": {
                "rev": "1-108ce4f3e2f178655c67170e987406b8"
            },
            "doc": {
                "_id": "4da74a0abb4896376622c6eeed0018f4",
                "_rev": "1-108ce4f3e2f178655c67170e987406b8",
                "roomID": "b52353e4f1f3dc2cc38f1afd560005fd",
                "completed": false,
                "completedBy": null,
                "requestedAt": 1448206702.81973,
                "dueBy": 1448206702.81973
            }
        }
  */
  public init(jsonData: [String : AnyObject]) {
    var requestedAtTimeInterval:Double?, dueByTimeInterval:Double?
    requestID = jsonData["id"] as? String
    
    let docBody = jsonData["doc"] as? [String: AnyObject]
    revision = docBody?["_rev"] as? String
    roomID = docBody?["roomID"] as? String
    requestedAtTimeInterval = docBody?["requestedAt"] as? Double
    dueByTimeInterval = docBody?["dueBy"] as? Double
    completed = docBody?["completed"] as? Bool
    completedBy = docBody?["completedBy"] as? String
    
    if let requestedAtTimeInterval = requestedAtTimeInterval {
      requestedAt = NSDate(timeIntervalSince1970: requestedAtTimeInterval)
    }
    
    if let dueByTimeInterval = dueByTimeInterval {
      dueBy = NSDate(timeIntervalSince1970: dueByTimeInterval)
    }
  }
}