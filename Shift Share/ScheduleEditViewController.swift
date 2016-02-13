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
        self.shiftFetchResultsController.delegate = self
        
    }
    
    
    //two sections if notes and shift exist, one if only one exists
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        //return 2, one for shift, one for section
        return 2
    }
    
    //number of rows in the table, populate with new schedule data cells
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        //section 0 is shift, either a newShift or the actual shift
        if section == 0 {
            return 1
        } else {
            //outside of section 0 is notes, return note count + 1 if notes exist, else 1 (for newNote)
            if let notes = self.notesFetchResultsController.fetchedObjects where notes.count != 0 {
                return notes.count + 1
            } else {
                return 1
            }
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
        
        if indexPath.section == 0 {
            if let shifts = self.shiftFetchResultsController.fetchedObjects where shifts.count != 0, let shift = shifts[indexPath.row] as? SSShift {
                print(shift)
                print(shift.type)
                print(shift.persistedType)
                print(shift.imageName)
                print(shift.title)
                print(shift.body)
                self.configureCell(cell, withItem: shift)
            } else {
                //create scratch shift
                let newShift = SSShift(type: nil, context: CoreDataStackManager.sharedInstance().scratchContext)
                newShift.title = "New Shift"
                self.configureCell(cell, withItem: newShift)
            }
        } else {
            if let notes = self.notesFetchResultsController.fetchedObjects where notes.count != 0, let note = notes[indexPath.row] as? SSNote {
                self.configureCell(cell, withItem: note)
            } else {
                let newNote = SSNote(title: "New Note", body: nil, context: CoreDataStackManager.sharedInstance().scratchContext)
                self.configureCell(cell, withItem: newNote)
            }
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
            if let shifts = self.shiftFetchResultsController.fetchedObjects where shifts.count != 0 {
                //shift exists in fetch, can be edited
                return true
            }
        } else {
            if let notes = self.notesFetchResultsController.fetchedObjects where notes.count != 0 {
                
                //notes exist in fetch, can be edited except for newNote item
                if indexPath.row != indexPath.length - 1 {
                    return true
                }
//                for note in notes {
//                    if let _ = note.schedule {
//                        return true
//                    } else {
//                        return false
//                    }
//                }
            }
        }
        //no item at the index (indicates newShift or newNote), cannot be edited
        return false
    }
    
    //remove shift or note
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        //perform the following if deleting
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            //handle shift or notes depending on section
            if indexPath.section == 0 {
                if let shift = self.shiftFetchResultsController.objectAtIndexPath(indexPath) as? SSShift {
                    CoreDataStackManager.sharedInstance().managedObjectContext.deleteObject(shift)
                }
            } else {
                if let note = self.notesFetchResultsController.objectAtIndexPath(indexPath) as? SSNote {
                    CoreDataStackManager.sharedInstance().managedObjectContext.deleteObject(note)
                }
            }
            //save context
            do {
                try CoreDataStackManager.sharedInstance().managedObjectContext.save()
            } catch {
                print("failed to delete shift or note object")
                //TODO: HANDLE ERROR
            }
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
//        self.schedule = nil
        
        //dismiss viewController
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    //user presses done button, commit all changes to schedule
//    func doneButtonPressed(sender: UIButton) {
//        
//        //if no schedule, return
//        guard let schedule = self.schedule else {
//            self.navigationController?.popToRootViewControllerAnimated(true)
//            return
//        }
//        
//        //remove newSchedule if it exists
//        if schedule.shift?.schedule == nil {
//            self.schedule?.shift = nil
//        }
//        
//        //remove newNote if it exists
//        if schedule.notes?.last?.schedule == nil {
//            self.schedule?.notes?.popLast()
//        }
//        
//        //if notes or scheudle exist, save schedule, otherwise alert the delegate
//        if schedule.shift != nil || schedule.notes != nil {
////            SSSchedule.sharedInstance().schedules[self.date.keyFromDate] = schedule
//            do {
//                try CoreDataStackManager.sharedInstance().managedObjectContext.save()
//            } catch {
//                //TODO: HANDLE ERROR
//            }
//        } else {
////            schedule.manager?.checkForShiftOrNotes(schedule)
//        }
//        
//        //dismiss viewController
//        self.navigationController?.popToRootViewControllerAnimated(true)
//    }
    
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

}