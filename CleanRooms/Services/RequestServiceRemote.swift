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