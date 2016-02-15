//
//  ScheduleEditViewController.swift
//  Shift Share
//
//  Created by Brian Josel on 12/10/15.
//  Copyright © 2015 Brian Josel. All rights reserved.
//

import UIKit
import JTCalendar
import Parse
import CoreData

//vc for creating/editing schedules
class ScheduleEditViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    
    //schedule that will be created for that date
    var schedule : SSSchedule!
    var date : NSDate!
    
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
        let fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStackManager.sharedInstance().managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchResultsController
        
    }()
    
    //shift fetch results controller
    lazy var shiftFetchResultsController : NSFetchedResultsController = {
       
        //create fetch
        let fetchRequest = NSFetchRequest(entityName: "SSShift")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "schedule == %@", self.schedule)
        
        //create and return controller
        let fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStackManager.sharedInstance().managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchResultsController
    }()
    
    override func viewWillAppear(animated: Bool) {

        //hide navBar
        self.navigationController?.navigationBar.hidden = true
        
        //perform fetches
        do {
            try self.shiftFetchResultsController.performFetch()
        } catch {
            print("failed to fetch shifts")
            //TODO: HANDLE ERROR
        }
        
        do {
            try self.notesFetchResultsController.performFetch()
        } catch {
            print("failed to fetch notes")
            //TODO: HANDLE ERROR
        }
        
        //reload table
        self.newScheduleTable.reloadData()
                
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
        self.dateLabel.text = self.date.readableDate
        
        //fetch controllers
        self.notesFetchResultsController.delegate = self
        self.notesFetchResultsController.sectionNameKeyPath
        self.shiftFetchResultsController.delegate = self
        
        //get items at store
        self.fetchNotes()
        self.fetchAndRepopShift()
        
    }
    
    
    //two sections if notes and shift exist, one if only one exists
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        //return 3, one for shift, a second for notes (if they exist) and a third for newNote
        return 3
    }
    
    //number of rows in the table, populate with new schedule data cells
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        //section 0 is shift, either a newShift or the actual shift
        if section == 0 {
            return self.shiftFetchResultsController.sections![0].numberOfObjects
        } else if section == 1 {
            //section one is notes, if notes exist its count, else 0
            return self.notesFetchResultsController.sections![0].numberOfObjects
        } else {
            //last section is for newNote
            return 1
        }
    }


    
    //creates cells for the table
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //create cell
        guard let cell = tableView.dequeueReusableCellWithIdentifier("SSTableViewCell") as? SSTableViewCell else {
                print("no cell made")
                self.navigationController?.popToRootViewControllerAnimated(true)
                return UITableViewCell()
        }
        
        //configure cells for each section
        if indexPath.section == 0 {
            let shift = self.shiftFetchResultsController.fetchedObjects![indexPath.row] as! SSShift
            self.configureCell(cell, withItem: shift)
        } else if indexPath.section == 1 {
            let note = self.notesFetchResultsController.fetchedObjects![indexPath.row] as! SSNote
            self.configureCell(cell, withItem: note)
        } else {
            let newNote = SSNote(title: "New Note", body: nil, context: CoreDataStackManager.sharedInstance().scratchContext)
            self.configureCell(cell, withItem: newNote)
        }
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
        //either in section 2 or no shift has no schedule set
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
                //get note and delete (no need to check for section 1, just being safe)
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
//            tbDataEditVC.selectedIndexPath = sender as? NSIndexPath
            tbDataEditVC.scheduleItem = self.getItemAtIndexPath(atIndexPath: sender as! NSIndexPath)
            tbDataEditVC.date = self.date
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

        //clear schedule from VC
//        self.schedule = nil
        
        //dismiss viewController
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    //user presses done button, commit all changes to schedule
    func doneButtonPressed(sender: UIButton) {
        
        //save context
        CoreDataStackManager.sharedInstance().saveContext()
        
        //dismiss viewController
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    //configures cell in tableView with item (either shift or note)
    func configureCell(cell: UITableViewCell, withItem item: SSScheduleItem) {

        //cast cell
        let cell = cell as! SSTableViewCell
        
        //set date in cell (for bookkeeping, may be removed later)
        cell.date = self.date
        
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
        }
        return scheduleItem
    }
    
    //fetches data from both stores, creates newShift if shift does not exist
    func fetchAndRepopShift() {
        
        //perform fetches
        self.fetchShifts()
        
        print(self.shiftFetchResultsController.fetchedObjects)
        
        //if no shift at fetch, create newShift
        if self.shiftFetchResultsController.fetchedObjects?.count == 0 {
            let shift = SSShift(type: SSShiftType.NEWSHIFT, context: CoreDataStackManager.sharedInstance().managedObjectContext)
            shift.schedule = self.schedule
            print(shift.title)
            CoreDataStackManager.sharedInstance().saveContext()
            self.fetchShifts()
            print(self.shiftFetchResultsController.fetchedObjects)
        }
    }
    
    //called when controller will change the content
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.newScheduleTable.beginUpdates()
    }
    
    //called when an object is changed
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        print("changing \(anObject)")
        
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
        print("changing \(sectionInfo)")
    }
    
    //called when controller finishes changing content
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.newScheduleTable.endUpdates()
    }
    
    //convencience method for fetching shifts
    func fetchShifts() {
        do {
            try self.shiftFetchResultsController.performFetch()
        } catch {
            //TODO: HANDLE ERROR
            print("failed to fetch shifts")
        }
    }
    
    //convencience method for fetching notes
    func fetchNotes() {
        do {
            try self.notesFetchResultsController.performFetch()
        } catch {
            //TODO: HANDLE ERROR
            print("failed to fetch notes")
        }
    }
}