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
    @IBOutlet weak var addShiftButton: UIButton!
    @IBOutlet weak var addNoteButton: UIButton!
    @IBOutlet weak var addShiftButtonSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var addNoteButtonSpaceConstraint: NSLayoutConstraint!
    
    //local references to FRCs in CoreDataStack
    let notesFetchResultsController : NSFetchedResultsController = CoreDataStackManager.sharedInstance().notesFetchResultsController
    let shiftFetchResultsController : NSFetchedResultsController = CoreDataStackManager.sharedInstance().shiftFetchResultsController
    
    //local coreData reference
    let coreDataRef = CoreDataStackManager.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        //delegate and datasource for tableView
        self.newScheduleTable.delegate = self
        self.newScheduleTable.dataSource = self
        
        //fetch controllers
        self.notesFetchResultsController.delegate = self
        self.shiftFetchResultsController.delegate = self
        
        //perform fetches
        self.coreDataRef.fetchShiftAndNotes(forSchedule: self.schedule, withHandler: {success, error in
            //if failed, alert user
            if !success {
                self.makeAlert(self, title: "Failed to Load Data", error: error! as NSError)
            }
        })
        
        //setup views
        self.cancelButton.setTitle("Cancel", forState: UIControlState.Normal)
        self.doneButton.setTitle("Done", forState: UIControlState.Normal)
        self.cancelButton.addTarget(self, action: #selector(self.cancelButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.doneButton.addTarget(self, action: #selector(self.doneButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.addShiftButton.setTitle("Add Shift", forState: UIControlState.Normal)
        self.addNoteButton.setTitle("Add Note", forState: UIControlState.Normal)
        self.addShiftButton.addTarget(self, action: #selector(self.addShift(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.addNoteButton.addTarget(self, action: #selector(self.addNote(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.addShiftButton.hidden = !(self.shiftFetchResultsController.fetchedObjects?.isEmpty)!
        self.addNoteButtonSpaceConstraint.constant = self.addShiftButton.hidden ? self.addShiftButtonSpaceConstraint.constant : 2.5 * self.addShiftButtonSpaceConstraint.constant
        
        self.menuBar.bringSubviewToFront(self.cancelButton)
        self.menuBar.bringSubviewToFront(self.doneButton)
        self.dateLabel.text = self.schedule.date!.readableDate
    }
    
    override func viewWillAppear(animated: Bool) {
        
        //hide navBar
        self.navigationController?.navigationBar.hidden = true
        
        //deselect all cells
        self.newScheduleTable.deselectAllCells()
        self.newScheduleTable.reloadData()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        print(self.shiftFetchResultsController.fetchedObjects)
        print(self.notesFetchResultsController.fetchedObjects)
    }
    
    //launches next VC to add a new shift
    func addShift(sender: UIButton) {
        print("adding shift")
        
        //perform segue to create new shift
        self.performSegueWithIdentifier("ItemVCSegueFromNew", sender: sender)
        
    }
    
    //launches next VC to add a new note
    func addNote(sender: UIButton) {
        print("adding note")
        
        //perform segue to create new note
        self.performSegueWithIdentifier("ItemVCSegueFromNew", sender: sender)
    }
    
    
    //two sections if notes and shift exist, one if only one exists
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        //return up to 2, one for shift if it exists, one for notes (if they exist
        //NOTE: THE SECTION ONLY CORRESPONDS TO THE TABLE SECTION, NOT THE FETCH SECTION
        //      THE FETCH SECTION IS ALWAYS ZERO AND MUST BE HANDLED ACCORDINGLY
        let count  = (self.shiftFetchResultsController.sections?.count)! + (self.notesFetchResultsController.sections?.count)!
        print(count)
        return count
        
    }
    
    //number of rows in the table, populate with new schedule data cells
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //configure number of rows for each section
        switch section {
//        case 0:
//            //new shift section, only populate if no shifts in fetch
//            return self.shiftFetchResultsController.fetchedObjects!.isEmpty ? 1 : 0
        case 0:
            //shift, only populate if a shift exists
            return self.shiftFetchResultsController.sections![section - 0].numberOfObjects
        case 1:
            //notes, only populate if notes exist
            return self.notesFetchResultsController.sections![section - 1].numberOfObjects
//        case 3:
//            //new note, is always populated with 1
//            return 1
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
        let fetchIndexPath = NSIndexPath(forRow: indexPath.row, inSection: 0)
        
        //configure cells for each section
        switch indexPath.section {
        case 0:
            //get shift
            scheduleItem = self.shiftFetchResultsController.objectAtIndexPath(fetchIndexPath) as! SSShift
        case 1:
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
        
//        //editing mode for shift or notes
//        if indexPath.section == 1 || indexPath.section == 2 {
//            return true
//        }
        
        //shift is in section 0 or in section 3
        return true//false

    }
    
    //remove shift or note
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        //perform the following if deleting
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            //adjust indexPath
            let controllerIndexPath = NSIndexPath(forRow: indexPath.row, inSection: 0)
            
            //handle shift or notes depending on section
            if indexPath.section == 0 {
                //if row can be deleted, shift must exist, using implicitly unwrapped optionals
                let shift = self.shiftFetchResultsController.objectAtIndexPath(controllerIndexPath) as! SSShift
                CoreDataStackManager.sharedInstance().managedObjectContext.deleteObject(shift)
            } else if indexPath.section == 1 {
                //if row can be deleted, note must exist, using implicitly unwrapped optionals
                print(indexPath.row)
                let note = self.notesFetchResultsController.objectAtIndexPath(controllerIndexPath) as! SSNote
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
            
            //if sender is NSIndexPath, then row from table was selected, send indexPath to next VC
            if sender is NSIndexPath {
                scheduleItemVC.scheduleItem = self.getItemAtIndexPath(atIndexPath: sender as! NSIndexPath)
                scheduleItemVC.configForShift = (sender as! NSIndexPath).section == 0
            } else {
                //sender is UIButton, implying that addShift or addNote was hit
                if let sender = sender as? UIButton {
                    if sender == self.addShiftButton {
                        //config for shift
                        scheduleItemVC.configForShift = true
                    } else {
                        //config for note
                        scheduleItemVC.configForShift = false
                    }
                }
            }
            
            //set schedule
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
//        let didRemoveNewShift = self.removeNewShift()
        
        //if newShift removed and no notes in store, remove schedule
        if /*didRemoveNewShift*/ self.shiftFetchResultsController.fetchedObjects?.count == 0 && self.notesFetchResultsController.fetchedObjects?.count == 0 {
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
//        self.removeNewShift()
        
        //save context
        CoreDataStackManager.sharedInstance().saveContext()
        
        //call cacheAndConfig using delegate
        self.delegate?.scheduleDidChange(self.schedule)
        
        //dismiss viewController
        self.popVCroutine()
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
//            case 0:
//                //newShift
//                cell.imageView?.image = nil
//                cell.textLabel?.text = "New Shift"
//                cell.detailTextLabel?.text = ""
//            case 3:
//                //newNote
//                cell.imageView?.image = UIImage(named: "Note")
//                cell.textLabel?.text = "New Note"
//                cell.detailTextLabel?.text = ""
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
    
//    //method to create new shift or note object
//    func makeNewScheduleItem(shiftOrButton: String)-> SSScheduleItem {
//        
//        //returned item
//        var scheduleItem : SSScheduleItem
//        
//        //make item depending if shift or note
//        switch shiftOrButton {
//        case "shift" :
//            scheduleItem = SSShift(type: .NEWSHIFT, context: CoreDataStackManager.sharedInstance().managedObjectContext)
//        case "note" :
//            scheduleItem = SSNote(title: "New Note", body: "Note Body", context: CoreDataStackManager.sharedInstance().managedObjectContext)
//        default :
//            //return empty note, should never get to this point
//            return SSNote()
//            
//        }
//        return scheduleItem
//    }
    
    //method to get item to be used in schedule editing
    func getItemAtIndexPath(atIndexPath indexPath: NSIndexPath) -> SSScheduleItem {
        
        //returned scheduleItem
        var scheduleItem : SSScheduleItem
        
        //fetchIndex
        let fetchIndexPath = NSIndexPath(forItem: indexPath.row, inSection: 0)
        
        //check table section
        switch indexPath.section {
//        case 0:
//            //new shift, make new shift object
//            scheduleItem = SSShift(type: .NEWSHIFT, context: CoreDataStackManager.sharedInstance().managedObjectContext)
        case 0:
            //shift in fetch
            scheduleItem = self.shiftFetchResultsController.objectAtIndexPath(fetchIndexPath) as! SSShift
        case 1:
            //note in fetch
            scheduleItem = self.notesFetchResultsController.objectAtIndexPath(fetchIndexPath) as! SSNote
//        case 3:
//            //new note, make new note object
//            scheduleItem = SSNote(title: "New Note", body: "Note Body", context: CoreDataStackManager.sharedInstance().managedObjectContext)
        default:
            //should never get to this point
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
                    path = NSIndexPath(forRow: indexPath.row, inSection: indexPath.section + 0)
                } else {
                    path = NSIndexPath(forRow: indexPath.row, inSection: indexPath.section + 1)
                }
            }
            return path
        }()
        
        let tableNewIndexPath : NSIndexPath? = {
            var path : NSIndexPath?
            if let newIndexPath = newIndexPath {
                if controller == self.shiftFetchResultsController {
                    path = NSIndexPath(forRow: newIndexPath.row, inSection: newIndexPath.section + 0)
                } else {
                    path = NSIndexPath(forRow: newIndexPath.row, inSection: newIndexPath.section + 1)
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
            print(tableIndexPath?.section)
            print(tableIndexPath?.row)
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
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        //create reference to allow mutation
        var sectionIndex : Int = sectionIndex
        
        //create new sectionIndex depending on which controller calls the delegate
        if controller == self.shiftFetchResultsController {
            sectionIndex += 0
        } else {
            sectionIndex += 1
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