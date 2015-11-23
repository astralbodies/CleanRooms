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

public struct RemoteRequest {
  public var requestID: String
  public var revision: String
  public var roomID: String
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
    requestID = jsonData["id"] as! String
    
    let docBody = jsonData["doc"] as? [String: AnyObject]
    revision = docBody?["_rev"] as! String
    roomID = docBody?["roomID"] as! String
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
  
  public init(requestID: String, revision: String, roomID: String, requestedAt: NSDate?, dueBy: NSDate?, completed: Bool?, completedBy: String?) {
    self.requestID = requestID
    self.revision = revision
    self.roomID = roomID
    self.requestedAt = requestedAt
    self.dueBy = dueBy
    self.completed = completed
    self.completedBy = completedBy
  }
  
  public func jsonDictionary() -> [String: AnyObject] {
    let dictionary:[String: AnyObject] = [
      "_id" : requestID,
      "_rev" : revision,
      "roomID" : roomID,
      "completed" : completed ?? false,
      "completedBy" : completedBy ?? NSNull(),
      "requestedAt" : requestedAt?.timeIntervalSince1970 ?? NSNull(),
      "dueBy" : dueBy?.timeIntervalSince1970 ?? NSNull()
    ]
    
    return dictionary
  }
}