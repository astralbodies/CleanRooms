//
//  RemoteRoom.swift
//  CleanRooms
//
//  Created by Aaron Douglas on 11/20/15.
//  Copyright © 2015 Razeware LLC. All rights reserved.
//

import Foundation

public struct RemoteRoom {
  public var area: Int?
  public var bathrooms: Int?
  public var beds: Int?
  public var roomID: String?
  public var roomNumber: String?

  /* Example data:
    {
        "id": "b52353e4f1f3dc2cc38f1afd560005fd",
        "key": "b52353e4f1f3dc2cc38f1afd560005fd",
        "value": {
            "rev": "4-6f76e54abe3fddbbba22e69903d93639"
        },
        "doc": {
            "_id": "b52353e4f1f3dc2cc38f1afd560005fd",
            "_rev": "4-6f76e54abe3fddbbba22e69903d93639",
            "area": 300,
            "beds": 1,
            "roomNumber": "100",
            "bathrooms": 1
        }
    }
  */
  public init(jsonData: [String : AnyObject]) {
    roomID = jsonData["id"] as? String
    
    let docBody = jsonData["doc"] as? [String: AnyObject]
    area = docBody?["area"] as? Int
    beds = docBody?["beds"] as? Int
    roomNumber = docBody?["roomNumber"] as? String
    bathrooms = docBody?["bathrooms"] as? Int
  }
}