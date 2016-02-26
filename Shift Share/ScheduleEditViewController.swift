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
    
    //outlets
    @IBOutlet weak var menuBar: JTCalendarMenuView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var newScheduleTable: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    
    //notes fetch results controller
    lazy var notesFetchResultsController : NSFetchedResultsController = {
        
        //create fetch
        let fetchRequest = NSFetchRequest(entityName: "SSNote")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "schedule == %@", self.schedule)
        
        //create and return controller
        //call cacheName notesEditVC to imply notes fetched in the editVC
        let fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStackManager.sharedInstance().managedObjectContext, sectionNameKeyPath: nil, cacheName: "notesEditVC")
        return fetchResultsController
        
    }()
    
    //shift fetch results controller
    //call cacheName shiftEditVC to imply shift fetched in the editVC
    lazy var shiftFetchResultsController : NSFetchedResultsController = {
       
        //create fetch
        let fetchRequest = NSFetchRequest(entityName: "SSShift")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "schedule == %@", self.schedule)
        
        //create and return controller
        let fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStackManager.sharedInstance().managedObjectContext, sectionNameKeyPath: nil, cacheName: "shiftEditVC")
        return fetchResultsController
    }()
    
    override func viewWillAppear(animated: Bool) {

        //hide navBar
        self.navigationController?.navigationBar.hidden = true
        
        //perform fetches
        self.fetchAndRepopShift()
        self.fetchNotes()
        
    }
    
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
        
    }
    
    
    //two sections if notes and shift exist, one if only one exists
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        //return 3, one for shifts,, one for notes (if they exist) and a third for newNote, which is always present
        //NOTE: THE SECTION ONLY CORRESPONDS TO THE TABLE SECTION, NOT THE FETCH SECTION
        //      THE FETCH SECTION IS ALWAYS ZERO AND MUST BE HANDLED ACCORDINGLY
        return 3
    }
    
    //number of rows in the table, populate with new schedule data cells
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //configure number of rows for each section
        if section == 0 {
            return self.shiftFetchResultsController.sections![0].numberOfObjects
        } else if section == 1 {
            //section one is notes, if notes exist its count, else 0
            return self.notesFetchResultsController.sections![0].numberOfObjects
        } else {
            //section 3 is for newNote
            return 1
        }
    }


    
    //creates cells for the table
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //create cell
        guard let cell = tableView.dequeueReusableCellWithIdentifier("SSTableViewCell") as? SSTableViewCell else {
                print("no cell made")
                self.navigationController?.popViewControllerAnimated(true)
                return UITableViewCell()
        }
        
        //item to pass on for cell configuration
        var scheduleItem : SSScheduleItem
        
        //configure cells for each section
        if indexPath.section == 0 {
            scheduleItem = self.shiftFetchResultsController.fetchedObjects![indexPath.row] as! SSShift
        } else if indexPath.section == 1 {
            scheduleItem = self.notesFetchResultsController.fetchedObjects![indexPath.row] as! SSNote
        } else {
            //configure newNote
            scheduleItem = SSNote(title: "New Note", body: nil, context: CoreDataStackManager.sharedInstance().scratchContext)
        }
        
        //pass item and cell on for configuration and return
        self.configureCell(cell, withItem: scheduleItem)
        return cell
    }
    
    //clicking cells launches VC to create shift
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //pass indexPath onto next VC, use to locate which shift or note is selected
        self.performSegueWithIdentifier("TBeditVCSegueFromNew", sender: indexPath)
        
    }
    
    //disable editing of newShift and newNote
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        //editing mode for shift
        if indexPath.section == 0 {
            let shift = self.shiftFetchResultsController.fetchedObjects![indexPath.row] as! SSShift
            if shift.type != SSShiftType.NEWSHIFT {
                //shift is not newShift, can be edited
                return true
            }
        } else if indexPath.section == 1 {
            //section 1 only populated if notes exist, can be deletec
            return true
        }
        
        //shift is NEWSHIFT or in section 2
        return false

    }
    
    //remove shift or note
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        //perform the following if deleting
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            //handle shift or notes depending on section
            if indexPath.section == 0 {
                //if row can be deleted, shift must exist, using implicitly unwrapped optionals
                let shift = self.shiftFetchResultsController.fetchedObjects![indexPath.row] as! SSShift
                CoreDataStackManager.sharedInstance().managedObjectContext.deleteObject(shift)
            } else if indexPath.section == 1 {
                //if row can be deleted, note must exist, using implicitly unwrapped optionals
                let note = self.notesFetchResultsController.fetchedObjects![indexPath.row] as! SSNote
                CoreDataStackManager.sharedInstance().managedObjectContext.deleteObject(note)
            }
            //save context
            CoreDataStackManager.sharedInstance().saveContext()
            self.fetchAndRepopShift()
        }
    }
    
    //segue to scheduleEditVC
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "TBeditVCSegueFromNew" {

            //create VC for show presentation
            let tbDataEditVC : TBDataEditViewController = segue.destinationViewController as! TBDataEditViewController
            tbDataEditVC.selectedIndexPath = sender as? NSIndexPath
            tbDataEditVC.scheduleItem = self.getItemAtIndexPath(atIndexPath: sender as! NSIndexPath)
            tbDataEditVC.schedule = self.schedule

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
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //user presses done button, commit all changes to schedule
    func doneButtonPressed(sender: UIButton) {
        
        //remove NEWSHIFT object if it exists
        self.removeNewShift()
        
        //save context
        CoreDataStackManager.sharedInstance().saveContext()
        
        //call cacheAndConfig,config UI methods in CalVC
        let calVC = self.navigationController?.viewControllers.first as! CalendarViewController
        calVC.cacheAndConfig(self.schedule)
        calVC.configUIViews(self.schedule.date!)
        
        //dismiss viewController
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //configures cell in tableView with item (either shift or note)
    func configureCell(cell: UITableViewCell, withItem item: SSScheduleItem) {

        //cast cell
        let cell = cell as! SSTableViewCell
                
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
    
    //method to get item to be used in schedule editing
    func getItemAtIndexPath(atIndexPath indexPath: NSIndexPath) -> SSScheduleItem {
        
        //returned scheduleItem
        var scheduleItem : SSScheduleItem
        
        //check section
        if indexPath.section == 0 {
            //item is a shift
            scheduleItem = self.shiftFetchResultsController.fetchedObjects![indexPath.row] as! SSShift
        } else if indexPath.section == 1 {
            //item is a note that exists from store since indexPath.section is 1
            scheduleItem = self.notesFetchResultsController.fetchedObjects![indexPath.row] as! SSNote
        } else {
            //seciton 3 implies newNote
            //no note in store, make new note
            scheduleItem = SSNote(title: "New Note", body: "Your note content", context: CoreDataStackManager.sharedInstance().managedObjectContext)
            CoreDataStackManager.sharedInstance().saveContext()
        }
        return scheduleItem
    }
    
    //fetches data from both stores, creates newShift if shift does not exist
    func fetchAndRepopShift() {
        
        //perform fetches
        self.fetchShifts()
        
        //if no shift at fetch, create newShift
        if self.shiftFetchResultsController.fetchedObjects?.count == 0 {
            let shift = SSShift(type: SSShiftType.NEWSHIFT, context: CoreDataStackManager.sharedInstance().managedObjectContext)
            shift.schedule = self.schedule
        }
    }
    
    //called when controller will change the content
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.newScheduleTable.beginUpdates()
    }
    
    //called when an object is changed
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        //create different indexPaths so handling tableView is easier considering that the fetchResultsControllers have one section each
        let oldIndexPath : NSIndexPath? = {
            var path : NSIndexPath?
            if let indexPath = indexPath {
                if controller == self.shiftFetchResultsController {
                    path = NSIndexPath(forRow: indexPath.row, inSection: 0)
                } else {
                    path = NSIndexPath(forRow: indexPath.row, inSection: 1)
                }
            }
            return path
        }()
        
        let newerIndexPath : NSIndexPath? = {
            var path : NSIndexPath?
            if let newIndexPath = newIndexPath {
                if controller == self.shiftFetchResultsController {
                    path = NSIndexPath(forRow: newIndexPath.row, inSection: 0)
                } else {
                    path = NSIndexPath(forRow: newIndexPath.row, inSection: 1)
                }
            }
            return path
        }()
        

        
        //make changes to table depending on changeType
        switch type {
        case .Insert :
            self.newScheduleTable.insertRowsAtIndexPaths([newerIndexPath!], withRowAnimation: .Fade)
        case .Delete :
            self.newScheduleTable.deleteRowsAtIndexPaths([oldIndexPath!], withRowAnimation: .Fade)
        case .Update :
            var scheduleItem : SSScheduleItem
            if controller == self.shiftFetchResultsController {
                scheduleItem = controller.objectAtIndexPath(oldIndexPath!) as! SSShift
            } else {
                scheduleItem = controller.fetchedObjects![oldIndexPath!.row] as! SSNote
            }
            let cell = self.newScheduleTable.cellForRowAtIndexPath(oldIndexPath!) as! SSTableViewCell
            self.configureCell(cell, withItem: scheduleItem)
        case .Move :
            self.newScheduleTable.deleteRowsAtIndexPaths([oldIndexPath!], withRowAnimation: .Fade)
            self.newScheduleTable.insertRowsAtIndexPaths([newerIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    //called when a section is changed
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        //add appropriate methods
    }
    
    //called when controller finishes changing content
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.newScheduleTable.endUpdates()
    }
    
    //convencience method for fetching shifts
    func fetchShifts() {
        
        //clear out cache
        NSFetchedResultsController.deleteCacheWithName("shiftEditVC")
        
        //attempt fetch
        do {
            try self.shiftFetchResultsController.performFetch()
        } catch {
            //TODO: HANDLE ERROR
            print("failed to fetch shifts")
        }
    }
    
    //convencience method for fetching notes
    func fetchNotes() {
        
        //clear out cashe
        NSFetchedResultsController.deleteCacheWithName("notesEditVC")
        
        //attempt fetch
        do {
            try self.notesFetchResultsController.performFetch()
        } catch {
            //TODO: HANDLE ERROR
            print("failed to fetch notes")
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
}