//
//  DetailViewController.swift
//  CleanRooms
//
//  Created by Aaron Douglas on 11/17/15.
//  Copyright © 2015 Razeware LLC. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UITableViewController {
  
  @IBOutlet weak var detailDescriptionLabel: UILabel!
  var managedObjectContext: NSManagedObjectContext!
  private let dateFormatter = NSDateFormatter()
  
  
  var detailItem: Request? {
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
    let requestService = RequestService(managedObjectContext: managedObjectContext)
    requestService.markRequestAsCompleted(detailItem!.requestID)
    
    do {
      try detailItem?.managedObjectContext?.save()
    } catch {
      print("Error while saving Request: \(error)")
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
      return 4
    } else {
      return 1
    }
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let identifier:String = {
      if self.detailItem == nil {
        return "NothingSelected"
      } else if indexPath.row < 3 {
        return "RightDetail"
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
    }
    
    return cell
  }
}

