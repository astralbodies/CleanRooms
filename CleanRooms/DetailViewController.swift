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

import UIKit
import CoreData

class DetailViewController: UITableViewController {

  var managedObjectContext: NSManagedObjectContext!
  private let dateFormatter = NSDateFormatter()

  private var notesTextField: UITextField!

  var detailItem: CleaningRequest? {
    didSet {
      // Update the view.
      self.tableView.reloadData()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    dateFormatter.dateStyle = .ShortStyle
    dateFormatter.timeStyle = .ShortStyle
    dateFormatter.locale = NSLocale.currentLocale()
  }

  @IBAction func markRequestAsCompleted() {
    let cleaningRequestService = CleaningRequestService(managedObjectContext: managedObjectContext)
    cleaningRequestService.markCleaningRequestAsCompleted(detailItem!.requestID!, notes: notesTextField.text)

    do {
      try detailItem?.managedObjectContext?.save()
    } catch {
      print("Error while saving CleaningRequest: \(error)")
    }

    detailItem = nil
    tableView.reloadData()
  }

}

// Table View Data Source Methods
extension DetailViewController {
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if detailItem != nil {
      return 5
    } else {
      return 1
    }
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let identifier: String = {
      if self.detailItem == nil {
        return "NothingSelected"
      } else if indexPath.row < 3 {
        return "RightDetail"
      } else if indexPath.row == 3 {
        return "Notes"
      } else {
        return "MarkCompleted"
      }
    }()

    let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)

    if identifier == "RightDetail" {
      switch indexPath.row {
      case 0:
        cell.textLabel?.text = "Room Number"
        cell.detailTextLabel?.text = detailItem?.room?.roomNumber
      case 1:
        cell.textLabel?.text = "Due By"
        cell.detailTextLabel?.text = "\(dateFormatter.stringFromDate(detailItem!.dueBy!))"
      default:
        cell.textLabel?.text = "Requested At"
        cell.detailTextLabel?.text = "\(dateFormatter.stringFromDate(detailItem!.requestedAt!))"
      }
    } else if identifier == "Notes" {
      notesTextField = cell.contentView.viewWithTag(100) as! UITextField
    }

    return cell
  }
}
