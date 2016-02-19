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

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

  var detailViewController: DetailViewController?
  var managedObjectContext: NSManagedObjectContext?
  let dateFormatter = NSDateFormatter()


  override func viewDidLoad() {
    super.viewDidLoad()

    dateFormatter.dateStyle = .NoStyle
    dateFormatter.timeStyle = .MediumStyle
    dateFormatter.locale = NSLocale.currentLocale()
  }

  override func viewWillAppear(animated: Bool) {
    self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
    super.viewWillAppear(animated)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - Segues

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showDetail" {
      if let indexPath = self.tableView.indexPathForSelectedRow {
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
        let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
        detailViewController = controller
        controller.managedObjectContext = managedObjectContext
        controller.detailItem = object as? CleaningRequest
        controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
        controller.navigationItem.leftItemsSupplementBackButton = true
      }
    }
  }

  // MARK: - Table View

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return self.fetchedResultsController.sections?.count ?? 0
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let sectionInfo = self.fetchedResultsController.sections![section]
    return sectionInfo.numberOfObjects
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
    self.configureCell(cell, atIndexPath: indexPath)
    return cell
  }

  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
  }

  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
      let context = self.fetchedResultsController.managedObjectContext
      context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)

      do {
        try context.save()
      } catch {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        //print("Unresolved error \(error), \(error.userInfo)")
        abort()
      }
    }
  }

  func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    let cleaningRequest = self.fetchedResultsController.objectAtIndexPath(indexPath) as! CleaningRequest
    cell.textLabel!.text = "Room \(cleaningRequest.room!.roomNumber!)"
    cell.detailTextLabel!.text = "Due: \(dateFormatter.stringFromDate(cleaningRequest.dueBy!))"
  }

  // MARK: - Fetched results controller

  lazy var fetchedResultsController: NSFetchedResultsController =  {
    let fetchRequest = NSFetchRequest()
    // Edit the entity name as appropriate.
    let entity = NSEntityDescription.entityForName("CleaningRequest", inManagedObjectContext: self.managedObjectContext!)
    fetchRequest.entity = entity
    fetchRequest.predicate = NSPredicate(format: "completed == %@", false)

    // Set the batch size to a suitable number.
    fetchRequest.fetchBatchSize = 20

    // Edit the sort key as appropriate.
    let sortDescriptor = NSSortDescriptor(key: "dueBy", ascending: true)
    let sortDescriptor2 = NSSortDescriptor(key: "room.roomNumber", ascending: true)

    fetchRequest.sortDescriptors = [sortDescriptor, sortDescriptor2]

    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
    fetchedResultsController.delegate = self

    do {
      try fetchedResultsController.performFetch()
    } catch {
      // Replace this implementation with code to handle the error appropriately.
      // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      //print("Unresolved error \(error), \(error.userInfo)")
      abort()
    }
    return fetchedResultsController
  }()

  func controllerWillChangeContent(controller: NSFetchedResultsController) {
    self.tableView.beginUpdates()
  }

  func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
    switch type {
    case .Insert:
      self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
    case .Delete:
      self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
    default:
      return
    }
  }

  func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
    switch type {
    case .Insert:
      tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
    case .Delete:
      tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
    case .Update:
      self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
    case .Move:
      tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
      tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
    }
  }

  func controllerDidChangeContent(controller: NSFetchedResultsController) {
    self.tableView.endUpdates()
  }

  /*
  // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.

  func controllerDidChangeContent(controller: NSFetchedResultsController) {
  // In the simplest, most efficient, case, reload the table view.
  self.tableView.reloadData()
  }
  */

  @IBAction func syncData(sender: UIBarButtonItem) {
    let cleaningRequestService = CleaningRequestService(managedObjectContext: managedObjectContext!)
    let cleaningRequestServiceRemote = CleaningRequestServiceRemote()
    let roomService = RoomService(managedObjectContext: managedObjectContext!)
    let roomServiceRemote = RoomServiceRemote()

    sender.enabled = false

    let syncService = SynchronizationService(roomService: roomService, roomServiceRemote: roomServiceRemote, cleaningRequestService: cleaningRequestService, cleaningRequestServiceRemote: cleaningRequestServiceRemote, managedObjectContext: managedObjectContext!)
    syncService.synchronizeAllData {
      dispatch_async(dispatch_get_main_queue()) {
        sender.enabled = true
        self.detailViewController?.detailItem = nil
        self.tableView.reloadData()
      }
      print("Synchronization complete.")
    }
  }

}
