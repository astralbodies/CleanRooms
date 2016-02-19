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

public struct RemoteRoom {
  public var area: Int
  public var bathrooms: Int
  public var beds: Int
  public var roomID: String
  public var revision: String
  public var roomNumber: String

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
  public init(jsonData: [String: AnyObject]) {
    roomID = jsonData["id"] as! String

    let docBody = jsonData["doc"] as? [String: AnyObject]
    revision = docBody?["_rev"] as! String
    area = docBody?["area"] as! Int
    beds = docBody?["beds"] as! Int
    roomNumber = docBody?["roomNumber"] as! String
    bathrooms = docBody?["bathrooms"] as! Int
  }
}
