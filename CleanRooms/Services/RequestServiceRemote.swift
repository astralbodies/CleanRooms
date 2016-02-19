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

public class CleaningRequestServiceRemote {
  private var urlSession: NSURLSession!

  public init() {
    urlSession = NSURLSession.sharedSession()
  }

  public init(urlSession: NSURLSession) {
    self.urlSession = urlSession
  }

  public func fetchAllRequests(completion: ([RemoteCleaningRequest]) -> Void) {
    let url = NSURL(string: "http://localhost:5984/requests/_all_docs?include_docs=true")!

    let urlRequest = NSMutableURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0 * 1000)
    urlRequest.HTTPMethod = "GET"
    urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")

    let task = urlSession.dataTaskWithRequest(urlRequest) { data, response, error in
      guard error == nil else {
        print("Error while fetching remote rooms: \(error)")
        completion([RemoteCleaningRequest]())
        return
      }

      var json = try? NSJSONSerialization.JSONObjectWithData(data!, options: []) as! [String: AnyObject]

      guard json != nil else {
        print("Nil data received from fetchAllRooms")
        completion([RemoteCleaningRequest]())
        return
      }

      let rows = json!["rows"] as! [[String: AnyObject]]
      var rooms = [RemoteCleaningRequest]()
      for roomDict in rows {
        rooms.append(RemoteCleaningRequest(jsonData: roomDict))
      }

      completion(rooms)
    }

    task.resume()
  }

  public func updateRemoteCleaningRequests(remoteCleaningRequests: [RemoteCleaningRequest], completion: (revisions: [String]?) -> Void) {
    guard remoteCleaningRequests.count > 0 else {
      completion(revisions: [String]())
      return
    }

    let url = NSURL(string: "http://localhost:5984/requests/_bulk_docs")!
    let urlRequest = NSMutableURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0 * 1000)
    urlRequest.HTTPMethod = "POST"
    urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
    urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

    let jsonArray = ["docs": remoteCleaningRequests.map { remoteCleaningRequest in
      return remoteCleaningRequest.jsonDictionary()
    }]

    do {
      let data = try NSJSONSerialization.dataWithJSONObject(jsonArray, options: [])
      urlRequest.HTTPBody = data
      urlRequest.addValue(String(data.length), forHTTPHeaderField: "Content-Length")
    } catch {
      completion(revisions: nil)
      return
    }

    let task = urlSession.dataTaskWithRequest(urlRequest) { data, response, error in
      guard error == nil else {
        print("Error while updating remote requests: \(error)")
        completion(revisions: nil)
        return
      }

      let json = try? NSJSONSerialization.JSONObjectWithData(data!, options: []) as! [[String: AnyObject]]

      guard json != nil else {
        print("Nil data received from updateRemoteCleaningRequests")
        completion(revisions: nil)
        return
      }

      // Typical response: [{"id":"4da74a0abb4896376622c6eeed0018f4","rev":"3-b9265d4ba6bf38e3e4228b047720694f"}]
      let revisions = json!.map { dictionary in
        return (dictionary["rev"] as? String) ?? ""
      }

      completion(revisions: revisions)
    }

    task.resume()
  }


  public func updateRemoteCleaningRequest(remoteCleaningRequest: RemoteCleaningRequest, completion: (revision: String?) -> Void) {
    let url = NSURL(string: "http://localhost:5984/requests/\(remoteCleaningRequest.requestID)")!
    let urlRequest = NSMutableURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0 * 1000)
    urlRequest.HTTPMethod = "PUT"
    urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
    urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

    do {
      let data = try NSJSONSerialization.dataWithJSONObject(remoteCleaningRequest.jsonDictionary(), options: [])
      urlRequest.HTTPBody = data
    } catch {
      completion(revision: nil)
      return
    }

    let task = urlSession.dataTaskWithRequest(urlRequest) { data, response, error in
      guard error == nil else {
        print("Error while updating remote cleaning request: \(error)")
        completion(revision: nil)
        return
      }

      var json = try? NSJSONSerialization.JSONObjectWithData(data!, options: []) as! [String: AnyObject]

      guard json != nil else {
        print("Nil data received from updateRemoteCleaningRequest")
        completion(revision: nil)
        return
      }

      // Typical response: {"ok":true,"id":"4da74a0abb4896376622c6eeed0018f4","rev":"3-b9265d4ba6bf38e3e4228b047720694f"}
      let revision = json!["rev"] as! String

      completion(revision: revision)
    }

    task.resume()

  }
}
