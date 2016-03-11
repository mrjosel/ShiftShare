//
//  ScheduleEditViewController.swift
//  Shift Share
//
//  Created by Brian Josel on 12/10/15.
//  Copyright © 2015 Brian Josel. All rights reserved.
//

import UIKit
import JTCalendar
import CoreData

//vc for creating/editing schedules
class ScheduleEditViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    
    //schedule (created in previous VC)
    var schedule : SSSchedule!
    
    //delegate
    var delegate : ScheduleEditViewControllerDelegate?
    
    //outlets
    @IBOutlet weak var menuBar: JTCalendarMenuView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var newScheduleTable: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    
//    //notes fetch results controller
//    lazy var notesFetchResultsController : NSFetchedResultsController = {
//        
//        //create fetch
//        let fetchRequest = NSFetchRequest(entityName: "SSNote")
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: true)]
//        fetchRequest.predicate = NSPredicate(format: "schedule == %@", self.schedule)
//        
//        //create and return controller
//        //call cacheName notesEditVC to imply notes fetched in the editVC
//        let fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStackManager.sharedInstance().managedObjectContext, sectionNameKeyPath: nil, cacheName: "notesEditVC")
//        return fetchResultsController
//        
//    }()
//    
//    //shift fetch results controller
//    //call cacheName shiftEditVC to imply shift fetched in the editVC
//    lazy var shiftFetchResultsController : NSFetchedResultsController = {
//       
//        //create fetch
//        let fetchRequest = NSFetchRequest(entityName: "SSShift")
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//        fetchRequest.predicate = NSPredicate(format: "schedule == %@", self.schedule)
//        
//        //create and return controller
//        let fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStackManager.sharedInstance().managedObjectContext, sectionNameKeyPath: nil, cacheName: "shiftEditVC")
//        return fetchResultsController
//    }()
    
    let notesFetchResultsController : NSFetchedResultsController = CoreDataStackManager.sharedInstance().notesFetchResultsController
    let shiftFetchResultsController : NSFetchedResultsController = CoreDataStackManager.sharedInstance().shiftFetchResultsController
    var predicate : NSPredicate!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        //delegate and datasource for tableView
        self.newScheduleTable.delegate = self
        self.newScheduleTable.dataSource = self
        
        //setup views
        self.cancelButton.setTitle("Cancel", forState: UIControlState.Normal)
        self.doneButton.setTitle("Done", forState: UIControlState.Normal)
        self.cancelButton.addTarget(self, action: "cancelButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        self.doneButton.addTarget(self, action: "doneButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        self.menuBar.bringSubviewToFront(self.cancelButton)
        self.menuBar.bringSubviewToFront(self.doneButton)
        self.dateLabel.text = self.schedule.date!.readableDate

        //fetch controllers
        self.notesFetchResultsController.delegate = self
        self.shiftFetchResultsController.delegate = self
        self.predicate = NSPredicate(format: "schedule == %@", self.schedule)
        self.notesFetchResultsController.fetchRequest.predicate = self.predicate
        self.shiftFetchResultsController.fetchRequest.predicate = self.predicate
        
        //perform fetches
        self.fetchShifts()
        self.fetchNotes()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        //hide navBar
        self.navigationController?.navigationBar.hidden = true
        
        //deselect all cells
        self.newScheduleTable.deselectAllCells()
        
    }
    
    
    //two sections if notes and shift exist, one if only one exists
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        //return 3, one for shifts,, one for notes (if they exist) and a third for newNote, which is always present
        //NOTE: THE SECTION ONLY CORRESPONDS TO THE TABLE SECTION, NOT THE FETCH SECTION
        //      THE FETCH SECTION IS ALWAYS ZERO AND MUST BE HANDLED ACCORDINGLY
        let count  = (self.shiftFetchResultsController.sections?.count)! + (self.notesFetchResultsController.sections?.count)! + 2//1
        print(count)
        return count
        
    }
    
    //number of rows in the table, populate with new schedule data cells
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //configure number of rows for each section
        switch section {
        case 0:
            //new shift section, only populate if no shifts in fetch
            return self.shiftFetchResultsController.fetchedObjects!.isEmpty ? 1 : 0
        case 1:
            //shift, only populate if a shift exists
            return self.shiftFetchResultsController.sections![section - 1].numberOfObjects
        case 2:
            //notes, only populate if notes exist
            return self.notesFetchResultsController.sections![section - 2].numberOfObjects
        case 3:
            //new note, is always populated with 1
            return 1
        default:
            //should never get to this point
            return 0
        }
    }


    
    //creates cells for the table
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //create cell
        guard let cell = tableView.dequeueReusableCellWithIdentifier("SSTableViewCell") as? SSTableViewCell else {
                print("no cell made")
            
                return UITableViewCell()
        }
        
        //item to pass on for cell configuration
        var scheduleItem : SSScheduleItem?
        
        //convenience indexPath for fetchig objects
        let fetchIndexPath = NSIndexPath(forItem: indexPath.row, inSection: 0)
        
        //configure cells for each section
        switch indexPath.section {
        case 1:
            //get shift
            scheduleItem = self.shiftFetchResultsController.objectAtIndexPath(fetchIndexPath) as! SSShift
        case 2:
            scheduleItem = self.notesFetchResultsController.objectAtIndexPath(fetchIndexPath) as! SSNote
        default:
            scheduleItem = nil
        }
        
        //pass item and cell on for configuration and return
        self.configureCell(cell, withItem: scheduleItem, forSection: indexPath.section)
        return cell
    }
    
    //clicking cells launches VC to create shift
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //pass indexPath onto next VC, use to locate which shift or note is selected
        self.performSegueWithIdentifier("ItemVCSegueFromNew", sender: indexPath)
        
    }
    
    //disable editing of newShift and newNote
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        //editing mode for shift or notes
        if indexPath.section == 1 || indexPath.section == 2 {
            return true
        }
        
        //shift is NEWSHIFT or in section 3
        return false

    }
    
    //remove shift or note
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        //perform the following if deleting
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            //handle shift or notes depending on section
            if indexPath.section == 1 {
                //if row can be deleted, shift must exist, using implicitly unwrapped optionals
                let shift = self.shiftFetchResultsController.fetchedObjects![indexPath.row] as! SSShift
                CoreDataStackManager.sharedInstance().managedObjectContext.deleteObject(shift)
            } else if indexPath.section == 2 {
                //if row can be deleted, note must exist, using implicitly unwrapped optionals
                print(indexPath.row)
                let note = self.notesFetchResultsController.fetchedObjects![indexPath.row] as! SSNote
                print(note)
                CoreDataStackManager.sharedInstance().managedObjectContext.deleteObject(note)
            }
            //save context
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }
    
    //segue to scheduleEditVC
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ItemVCSegueFromNew" {

            //create VC for show presentation
            let scheduleItemVC : ScheduleItemViewController = segue.destinationViewController as! ScheduleItemViewController
            scheduleItemVC.selectedIndexPath = sender as? NSIndexPath
            scheduleItemVC.scheduleItem = self.getItemAtIndexPath(atIndexPath: sender as! NSIndexPath)
            scheduleItemVC.schedule = self.schedule

        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //user presses cancel button
    func cancelButtonPressed(sender: UIButton) {
        
        //remove newShift
        let didRemoveNewShift = self.removeNewShift()
        
        //if newShift removed and no notes in store, remove schedule
        if didRemoveNewShift && self.notesFetchResultsController.fetchedObjects?.count == 0 {
            //no shift and no notes, remove schedule
            CoreDataStackManager.sharedInstance().managedObjectContext.deleteObject(self.schedule)
        }
        
        //save context
        CoreDataStackManager.sharedInstance().saveContext()
        
        //clear out schedule (probably not needed)
        self.schedule = nil
        
        //dismiss viewController
//        self.navigationController?.popViewControllerAnimated(true)
        self.popVCroutine()
    }
    
    //user presses done button, commit all changes to schedule
    func doneButtonPressed(sender: UIButton) {
        
        //remove NEWSHIFT object if it exists
        self.removeNewShift()
        
        //save context
        CoreDataStackManager.sharedInstance().saveContext()
        
        //call cacheAndConfig using delegate
        self.delegate?.scheduleDidChange(self.schedule)
        
        //dismiss viewController
        self.popVCroutine()
//        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //configures cell in tableView with item (either shift or note)
    func configureCell(cell: UITableViewCell, withItem item: SSScheduleItem?, forSection section: Int?) {

        //cast cell
        guard let cell = cell as? SSTableViewCell else {
            //cell not SSTableViewCell, return blank cell
            return 
        }
        if let section = section {
            //check for scheduleItem
            switch section {
                //no item
            case 0:
                //newShift
                cell.imageView?.image = nil
                cell.textLabel?.text = "New Shift"
                cell.detailTextLabel?.text = ""
            case 3:
                //newNote
                cell.imageView?.image = UIImage(named: "Note")
                cell.textLabel?.text = "New Note"
                cell.detailTextLabel?.text = ""
            default:
                if let item = item {
                    //set cell properties
                    if let imageName = item.imageName {
                        cell.imageView?.image = UIImage(named: imageName)
                    } else {
                        cell.imageView?.image = nil
                    }
                    cell.textLabel?.text = item.title
                    cell.detailTextLabel?.text = item.body
                    
                    //hide detail label if its newNote (end of tableData)
                    cell.detailTextLabel?.hidden = item.schedule == nil ? true : false
                }
            }
        }
    }
    
    //method to get item to be used in schedule editing
    func getItemAtIndexPath(atIndexPath indexPath: NSIndexPath) -> SSScheduleItem {
        
        //returned scheduleItem
        var scheduleItem : SSScheduleItem
        
        //fetchIndex
        let fetchIndexPath = NSIndexPath(forItem: indexPath.row, inSection: 0)
        
        //check table section
        switch indexPath.section {
        case 0:
            //new shift, make new shift object
            scheduleItem = SSShift(type: .NEWSHIFT, context: CoreDataStackManager.sharedInstance().managedObjectContext)
        case 1:
            //shift in fetch
            scheduleItem = self.shiftFetchResultsController.objectAtIndexPath(fetchIndexPath) as! SSShift
        case 2:
            //note in fetch
            scheduleItem = self.notesFetchResultsController.objectAtIndexPath(fetchIndexPath) as! SSNote
        case 3:
            //new note, make new note object
            scheduleItem = SSNote(title: "New Note", body: "Note Body", context: CoreDataStackManager.sharedInstance().managedObjectContext)
        default:
            return SSNote()
        }
        return scheduleItem
    }
    
    //called when controller will change the content
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        self.newScheduleTable.beginUpdates()
    }
    
    //called when an object is changed
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        //create different indexPaths so handling tableView is easier considering that the fetchResultsControllers have one section each
        let tableIndexPath : NSIndexPath? = {
            var path : NSIndexPath?
            if let indexPath = indexPath {
                if controller == self.shiftFetchResultsController {
                    path = NSIndexPath(forRow: indexPath.row, inSection: indexPath.section + 1)
                } else {
                    path = NSIndexPath(forRow: indexPath.row, inSection: indexPath.section + 2)
                }
            }
            return path
        }()
        
        let tableNewIndexPath : NSIndexPath? = {
            var path : NSIndexPath?
            if let newIndexPath = newIndexPath {
                if controller == self.shiftFetchResultsController {
                    path = NSIndexPath(forRow: newIndexPath.row, inSection: newIndexPath.section + 1)
                } else {
                    path = NSIndexPath(forRow: newIndexPath.row, inSection: newIndexPath.section + 2)
                }
            }
            return path
        }()
        print(type)
        //attempt changes
        switch type {
        case .Insert :
            self.newScheduleTable.insertRowsAtIndexPaths([tableNewIndexPath!], withRowAnimation: .Fade)
        case .Delete :
            self.newScheduleTable.deleteRowsAtIndexPaths([tableIndexPath!], withRowAnimation: .Fade)
        case .Update :
            //get cell from table
            guard let cell = self.newScheduleTable.cellForRowAtIndexPath(tableIndexPath!) as? SSTableViewCell else {
                //failed to cast cell, alert user
                self.makeAlert(self, title: "Critical UI Error", error: nil)
                return
            }
            
            //get schedule item
            let scheduleItem = self.getItemAtIndexPath(atIndexPath: tableIndexPath!)
            
            //configure cell with item
            self.configureCell(cell, withItem: scheduleItem, forSection: tableIndexPath!.section)
        case .Move :
            //delete cell at adjustedIndexPath, and insert row at adjustedNewIndexPath
            self.newScheduleTable.deleteRowsAtIndexPaths([tableIndexPath!], withRowAnimation: .Fade)
            self.newScheduleTable.insertRowsAtIndexPaths([tableNewIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    //called when a section is changed
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, var atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        //create new sectionIndex depending on which controller calls the delegate
        if controller == self.shiftFetchResultsController {
            sectionIndex += 1
        } else {
            sectionIndex += 2
        }
        
        //insert or delete sections with updated sectionIndex
        switch type {
        case .Insert :
            self.newScheduleTable.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete :
            self.newScheduleTable.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default :
            return
        }
    }
    
    //called when controller finishes changing content
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        self.newScheduleTable.endUpdates()
    }
    
    //convencience method for fetching shifts
    func fetchShifts() {
        
        //clear out cache
        NSFetchedResultsController.deleteCacheWithName("shift")//EditVC")
        
        //attempt fetch
        do {
            try self.shiftFetchResultsController.performFetch()
        } catch {
            
            //alert user that app failed to load date
            self.makeAlert(self, title: "Failed to Load Shift", error: error as NSError)
        }
    }
    
    //convencience method for fetching notes
    func fetchNotes() {
        
        //clear out cashe
        NSFetchedResultsController.deleteCacheWithName("notes")//EditVC")
        
        //attempt fetch
        do {
            try self.notesFetchResultsController.performFetch()
        } catch {

            //alert user that app failed to load date
            self.makeAlert(self, title: "Failed to Load Notes", error: error as NSError)
        }
    }
    
    //removes newShift, if it exists, if it doesn't exist, function call does nothing
    //function returns bool, if needed
    func removeNewShift() -> Bool {
        
        var didRemove : Bool = false
        
        if let shift = self.shiftFetchResultsController.fetchedObjects?.first as? SSShift {
            if shift.type == SSShiftType.NEWSHIFT {
                CoreDataStackManager.sharedInstance().managedObjectContext.deleteObject(shift)
                didRemove = true
            }
        }
        return didRemove
    }
    
    //pop VC routine
    func popVCroutine() {
        NSFetchedResultsController.deleteCacheWithName("shift")
        NSFetchedResultsController.deleteCacheWithName("notes")
        self.notesFetchResultsController.delegate = nil
        self.notesFetchResultsController.fetchRequest.predicate = nil
        self.shiftFetchResultsController.fetchRequest.predicate = nil
        self.shiftFetchResultsController.delegate = nil
        self.navigationController?.popViewControllerAnimated(true)
    }
}