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
        
    }
    
    
    //two sections if notes and shift exist, one if only one exists
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        //return 4, one for newShift, one for the actual shift if it exists, one for notes (if they exist) and a fourth for newNote, which is always present
        //NOTE: THE SECTION ONLY CORRESPONDS TO THE TABLE SECTION, NOT THE FETCH SECTION
        //      THE FETCH SECTION IS ALWAYS ZERO AND MUST BE HANDLED ACCORDINGLY
        return 4
    }
    
    //number of rows in the table, populate with new schedule data cells
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //configure number of rows for each section
        if section == 0 {
            //section is newNote, should only exist if a shift is not in the store
            if let shifts = self.shiftFetchResultsController.fetchedObjects where shifts.count != 0 {
                //TODO: FIX THIS BUG!!!!
                return 0
            } else {
                return 1
            }
        } else if section == 1 {
            //section 1 is for a shift from the store
            let sectionInfo = self.shiftFetchResultsController.sections![0]
            print(self.shiftFetchResultsController.fetchedObjects)
            print(sectionInfo.numberOfObjects)
            return sectionInfo.numberOfObjects
        } else if section == 2 {
            //section 2 is for notes from the store
            let sectionInfo = self.notesFetchResultsController.sections![0]
            print(self.notesFetchResultsController.fetchedObjects)
            print(sectionInfo.numberOfObjects)
            return sectionInfo.numberOfObjects
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
                self.navigationController?.popToRootViewControllerAnimated(true)
                return UITableViewCell()
        }

        //section
        let section = indexPath.section
        
        //item to pass on for cell configuration
        var scheduleItem : SSScheduleItem
        
        //configure cells for each section
        if section == 0 {
            //configure newShift
            scheduleItem = SSShift(type: nil, context: CoreDataStackManager.sharedInstance().scratchContext)
            scheduleItem.title = "New Shift"
        } else if section == 1 {
            //configure shift from store
            scheduleItem = self.shiftFetchResultsController.fetchedObjects![indexPath.row] as! SSShift
        } else if section == 2 {
            //configure note from store
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
        
        //section
        let section = indexPath.section
        
        if section == 0 || section == 3 {
            //can't edit new shift or new note
            return false
        }
        
        //can edit sections 1 and 2 (shift and note from store)
        return true
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
                let note = self.notesFetchResultsController.fetchedObjects![indexPath.row] as! SSNote
                CoreDataStackManager.sharedInstance().managedObjectContext.deleteObject(note)
            }
            //save context
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }
    
    //segue to scheduleEditVC
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "TBeditVCSegueFromNew" {

            //create VC for show presentation
            let tbDataEditVC : TBDataEditViewController = segue.destinationViewController as! TBDataEditViewController
            tbDataEditVC.selectedIndexPath = sender as? NSIndexPath
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
        self.schedule = nil
        
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
                    path = NSIndexPath(forRow: indexPath.row, inSection: 1)
                } else {
                    path = NSIndexPath(forRow: indexPath.row, inSection: 2)
                }
            }
            return path
        }()
        
        let newerIndexPath : NSIndexPath? = {
            var path : NSIndexPath?
            if let newIndexPath = newIndexPath {
                if controller == self.shiftFetchResultsController {
                    path = NSIndexPath(forRow: newIndexPath.row, inSection: 1)
                } else {
                    path = NSIndexPath(forRow: newIndexPath.row, inSection: 2)
                }
            }
            return path
        }()
        

        
        //make changes to table depending on changeType
        switch type {
        case .Insert :
            print(newerIndexPath)
            self.newScheduleTable.insertRowsAtIndexPaths([newerIndexPath!], withRowAnimation: .Fade)
        case .Delete :
            print(oldIndexPath)
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

}