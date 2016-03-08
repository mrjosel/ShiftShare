//
//  CalendarViewController.swift
//  Shift Share
//
//  Created by Brian Josel on 11/12/15.
//  Copyright © 2015 Brian Josel. All rights reserved.
//

import UIKit
import JTCalendar
import Foundation
import CoreData

//main calendarView
class CalendarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, JTCalendarDelegate, NSFetchedResultsControllerDelegate, MenuViewControllerDelegate, ScheduleEditViewControllerDelegate {

    //calendar manager
    var calendarManager : JTCalendarManager!
    
    //date is selected when a user touches that dayView
    var selectedDate : NSDate! {
        didSet {
            
            //store date in defaults, each time it is set
            self.userDefaults.setValue(self.selectedDate, forKey: "selectedDate")
        }
    }
    
    //currently loggin in user
    var user : SSUser!
    
    //speeds up memory access if copying schedules to a local dict and then keying off extension of NSDate (keyFromDate)
    var schedulesDict : [String : SSSchedule]!

    //user defaults, used to load date after user launches app
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    //outlets
    @IBOutlet weak var monthSelectorView: JTCalendarMenuView!
    @IBOutlet weak var calendarView: JTHorizontalCalendarView!
    @IBOutlet weak var dayViewTableView: UITableView!
    @IBOutlet weak var calendarViewHeight: NSLayoutConstraint!
    @IBOutlet weak var leftSSButton: SSButton!
    @IBOutlet weak var rightSSButton: SSButton!
    @IBOutlet weak var noScheduleLabel: UILabel!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    
    //fetched results controller
    lazy var scheduleFetchResultsController : NSFetchedResultsController = {
        
        //create fetch request
        let fetchRequest = NSFetchRequest(entityName: "SSSchedule")
        
        //create predicate
        let predicate = NSPredicate(format: "user  == %@", self.user)
        
        //make sort descriptor
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        fetchRequest.predicate = predicate
        
        //create controller and return
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStackManager.sharedInstance().managedObjectContext, sectionNameKeyPath: nil, cacheName: "schedule")
        
        return fetchedResultsController
    }()
    
    lazy var shiftFetchResultsController : NSFetchedResultsController = {
        
        //create fetch request
        let fetchRequest = NSFetchRequest(entityName: "SSShift")
        
        //make sort descriptor
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        //create controller and return
        //set cacheName to "shiftCalVC" to imply shifts cache fetched in the CalendarVC
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStackManager.sharedInstance().managedObjectContext, sectionNameKeyPath: nil, cacheName: "shiftCalVC")
        
        return fetchedResultsController
    }()
    
    lazy var notesFetchResultsController : NSFetchedResultsController = {
        
        //create fetch request
        let fetchRequest = NSFetchRequest(entityName: "SSNote")
        
        //make sort descriptor
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: true)]
        
        //create controller and return
        //set cacheName to "notesCalVC" to imply notes cache fetched in the CalendarVC
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStackManager.sharedInstance().managedObjectContext, sectionNameKeyPath: nil, cacheName: "notesCalVC")
        
        return fetchedResultsController
    }()
    
    //do anytime view will show
    override func viewWillAppear(animated: Bool) {
        
        //deselect all cells
        self.dayViewTableView.deselectAllCells()
    
        //hide navBar
        self.navigationController?.navigationBar.hidden = true
        
    }

    override func viewDidLoad() {

        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
                
        //delegate and dataSource for tableView
        self.dayViewTableView.delegate = self
        self.dayViewTableView.dataSource = self
        
        //create calendar manager, set vc to calendar manager delegate
        self.calendarManager = JTCalendarManager()
        self.calendarManager.delegate = self
        
        //start with last date viewed by user
        self.selectedDate = {
            
            //if date exists in the defaults, return
            if let date = self.userDefaults.valueForKey("selectedDate") as? NSDate {
                return date
            }
            //no date in defaults, set date to today
            return NSDate()
            }()
        
        //fetchedResultsControllerDelegates
        self.shiftFetchResultsController.delegate = self
        self.notesFetchResultsController.delegate = self
        self.scheduleFetchResultsController.delegate = self
        
        //fetch schedules
        self.fetchSchedules()
        
        //create buttons for bottomToobar
        let menuButton = UIBarButtonItem(title: "Menu", style: .Plain, target: self, action: "showMenu")
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        let buttons : [UIBarButtonItem] = [menuButton, flexibleSpace]
        
        //setup views
        self.calendarManager.menuView = self.monthSelectorView
        self.calendarManager.contentView = self.calendarView
        self.calendarManager.setDate(NSDate())
        self.leftSSButton.hostViewController = self
        self.rightSSButton.hostViewController = self
        self.noScheduleLabel.text = "No Schedule"
        self.rightSSButton.ssButtonType = .TODAY
        self.monthSelectorView.bringSubviewToFront(self.leftSSButton)
        self.monthSelectorView.bringSubviewToFront(self.rightSSButton)
        self.dayViewTableView.allowsMultipleSelectionDuringEditing = false
        self.bottomToolBar.items = buttons


        //config views depending on schedule content
        self.configUIViews(self.selectedDate)

    }
    
    //delegate method that produces UIView conforming to JTCalendarDay protocol, returns custom ShiftShareDayView object
    func calendarBuildDayView(calendar: JTCalendarManager!) -> UIView! {

        //return SSDayView
        return SSDayView()
    }
    
    //delegate method to prepare day view
    func calendar(calendar: JTCalendarManager!, prepareDayView dayView: UIView!) {
        
        //cast dayView to ShiftShareDayView
        guard let dayView = dayView as? SSDayView else {
            
            //failed to cast
            self.makeAlert(self, title: "Critical Error : UI", error: nil)
            return
        }
        
        //format for today's date
        if calendar.dateHelper.date(NSDate(), isTheSameDayThan: dayView.date) {
            
            //set UI accordingly
            dayView.backgroundColor = UIColor.todayColor()
            dayView.alpha = 1.0
            dayView.dotView.backgroundColor = UIColor.whiteColor()
            dayView.textLabel.textColor = UIColor.blackColor()
        
        //selected date
        } else if self.selectedDate != nil && calendar.dateHelper.date(self.selectedDate, isTheSameDayThan: dayView.date) {
            
            //set UI accordingly
            dayView.alpha = 0.5
            dayView.backgroundColor = UIColor.lightGrayColor()
            dayView.dotView.backgroundColor = UIColor.whiteColor()
            dayView.textLabel.textColor = UIColor.blackColor()
            
        
        //other month
        } else if !calendar.dateHelper.date(self.calendarView.date, isTheSameMonthThan: dayView.date) {

            //set UI accordingly
            dayView.backgroundColor = UIColor.clearColor()
            dayView.alpha = 1.0
            dayView.dotView.backgroundColor = UIColor.redColor()
            dayView.textLabel.textColor = UIColor.lightGrayColor()
            
        //another day of the current month
        } else {
            
            //set UI accordingly
            dayView.backgroundColor = UIColor.clearColor()
            dayView.alpha = 1.0
            dayView.dotView.backgroundColor = UIColor.redColor()
            dayView.textLabel.textColor = UIColor.blackColor()
        }
        
        //config SSDayView specific params
        self.configSSDayView(dayView)

    }
    
    //code for handling touching the dayView of the calendar
    func calendar(calendar: JTCalendarManager!, didTouchDayView dayView: UIView!) {
        
        //cast dayView to ShiftShareDayView
        guard let dayView = dayView as? SSDayView else {
            
            //failed to cast
            self.makeAlert(self, title: "Critical Error : UI", error: nil)
            return
        }
        
        //set date
        self.selectedDate = dayView.date

        //animation for the dayView
        UIView.transitionWithView(dayView, duration: 0.1, options: UIViewAnimationOptions(), animations: {calendar.reload()}, completion: nil)
        
        //load the previous or next page if a day from another month is selected
        if !calendar.dateHelper.date(self.calendarView.date, isTheSameMonthThan: dayView.date) {
            
            //check if date is in the future
            if self.calendarView.date.compare(dayView.date) == NSComparisonResult.OrderedAscending {
                
                //date is next month, advance to next month
                self.calendarView.loadNextPageWithAnimation()
                
            } else {
                //date is last month, backtrack to prior month
                self.calendarView.loadPreviousPageWithAnimation()
            }
        }
        
        //config UI views
        self.configUIViews(self.selectedDate)

        //reload table
        self.dayViewTableView.reloadData()

    }
    
    //config UI views depending on date
    func configUIViews(date: NSDate) {
        if let schedule = self.schedulesDict[date.keyFromDate] {
            //scheudle for this date, config UI accordingly
            self.fetchShiftAndNotes(forSchedule: schedule)
            self.leftSSButton.ssButtonType = .EDIT
            self.dayViewTableView.reloadData()
            self.dayViewTableView.hidden = false
            self.noScheduleLabel.hidden = true
        } else {
            //no schedule
            self.leftSSButton.ssButtonType = .NEW
            self.dayViewTableView.hidden = true
            self.noScheduleLabel.hidden = false
        }
    }
    
    //config SSDayView specific
    func configSSDayView(dayView : SSDayView) {
        
        //set image and dotViews accordingly if shift or notes exist
        guard let schedule = self.schedulesDict[dayView.date.keyFromDate] else {
            //no schedule, keep defaults
            //NOTE: This is likely redundant (the following two params are hidden by default,
            //      but it fixes a bug in the JTCalendar Framework where dayViews without schedules have shift images
            //      and dotViews displayed.  The JTCalendar example project has a similar method in its viewController.
            dayView.dotView.hidden = true
            dayView.ssDVImageView.hidden = true
            return
        }
        
        //get shifts and notes
        self.fetchShiftAndNotes(forSchedule: schedule)
        
        //set image
        if let shift = self.shiftFetchResultsController.fetchedObjects?.first as? SSShift, let imageName = shift.imageName {
            dayView.ssDVImageView.image = UIImage(named: imageName)
            dayView.ssDVImageView.hidden = false
        } else {
            dayView.ssDVImageView.image = nil
            dayView.ssDVImageView.hidden = true
        }
        
        //display dotView if notes exist
        if let notes = self.notesFetchResultsController.fetchedObjects where notes.count != 0 {
            dayView.dotView.hidden = false
        } else {
            dayView.dotView.hidden = true
        }
        
    }
    
    //cache's schedule in schedulesDict, performs all operations necessary to configure the tableView, UI if anything is to change
    //This can also be called from other VCs that are popping off the stack back to this VC
    func cacheAndConfig(schedule : SSSchedule?) {
        
        //unwrap schedule
        if let schedule = schedule {
            
            //if schedule is not in schedulesDict, add it
            if self.schedulesDict[schedule.date!.keyFromDate] == nil {
                self.schedulesDict[schedule.date!.keyFromDate] = schedule
            }
            
        }
        
        //reload calendar
        self.calendarManager.reload()

    }
    
    //functions to carry out when Today/Cancel button is pressed based on which Type the button is
    func editCancelTodayButtonPressed(sender: SSButton) {
        
        //check which type button is
        switch sender.ssButtonType {
            //Today Button
        case .TODAY :
            //select today's date, dayView set calendarManager date to today, reload table
            self.selectedDate = NSDate()
            self.calendarManager.setDate(NSDate())
            self.weekViewEnabled(false)
            
            //Edit Button
        case .NEW :
            
            let newSchedule = SSSchedule(forDate: (self.selectedDate), forUser: self.user, context: CoreDataStackManager.sharedInstance().managedObjectContext)
            
            //segue to scheduleEditVC only
            self.performSegueWithIdentifier("scheduleEditVCsegue", sender: newSchedule)
            
            
        case .EDIT :
            
            let scheduleToEdit = self.schedulesDict[self.selectedDate.keyFromDate] 
            
            //segue to VC to create schedule
            self.performSegueWithIdentifier("scheduleEditVCsegue", sender: scheduleToEdit)
            
        case .DONE :        //TODO: REMOVE???
            //commit changes
            //TODO: MAKE METHOD TO SAVE CHANGES
            
            //go back to month view
            self.weekViewEnabled(false)

        }
    }
    
    //two sections, one for shift, one for notes
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 2
    }
    
    //number of rows in tableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //set number of rows depending on each section and objects count
        if section == 0 {
            
            //section 0 gets shifts
            return self.shiftFetchResultsController.fetchedObjects?.count ?? 0
        } else {
            
            //section 1 gets notes
            return self.notesFetchResultsController.fetchedObjects?.count ?? 0
        }
    }
    
    //creates cells for tableView
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        //create cell
        guard let cell = tableView.dequeueReusableCellWithIdentifier("SSTableViewCell") as? SSTableViewCell else {
            print("no cell made")
            return UITableViewCell()
        }
        
        //configure cell based on section and fetched contents
        if indexPath.section == 0 {
            //config section 0 for shifts if they exist
            if let shifts = self.shiftFetchResultsController.fetchedObjects where shifts.count != 0, let shift = shifts[indexPath.row] as? SSShift {
                self.configureCell(cell, withItem: shift)
            }
        } else {
            //config section 1 for notes if they exist
            if let notes = self.notesFetchResultsController.fetchedObjects where notes.count != 0, let note = notes[indexPath.row] as? SSNote {
                self.configureCell(cell, withItem: note)
            }
        }
        
        //return cell
        return cell
    }
    
    //tapping cells launches detail view or launches edit mode if selected while in edit mode
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //perform segue to editVC
        self.performSegueWithIdentifier("TBeditVCSegueFromCal", sender: indexPath)
    }
    
    //keep height at 30 for section 0, 0 for section 1 (do not want a header visible)
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 30 : 0
    }
    
    //header for table view, displays selected date
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        //create view with frame
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30))
        headerView.backgroundColor = UIColor.whiteColor()
        headerView.tag = section
        
        //create label with readable date, add to header
        let headerString = UILabel(frame: CGRect(x: 10, y: 5, width: headerView.frame.width, height: headerView.frame.height - 10)) as UILabel
        headerString.text = self.selectedDate?.readableDate
        headerString.font = UIFont(name: ".SFUIText-Regular", size: 15)
        headerView.addSubview(headerString)
        
        //return header
        return headerView
    }
    
    
    //allow editing, 
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    //remove shift or note
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {

        //perform the following if deleting
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            //check if shift
            if indexPath.section == 0 {
                let shift = self.shiftFetchResultsController.fetchedObjects![indexPath.row] as! SSShift
                CoreDataStackManager.sharedInstance().managedObjectContext.deleteObject(shift)
            } else {
                //object is note
                let note = self.notesFetchResultsController.fetchedObjects![indexPath.row] as! SSNote
                CoreDataStackManager.sharedInstance().managedObjectContext.deleteObject(note)
            }
            
            //save context
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }
    
    //called when schedule is changed
    func scheduleDidChange(schedule: SSSchedule) {
        //cache new schedule and config views
        self.cacheAndConfig(schedule)
        self.configUIViews(schedule.date!)
    }
    
    //handles segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let segueID = segue.identifier! as String
        
        switch segueID {
        case "ItemVCSegueFromCal" :
            
            //schedule item to pass to nextVC, and indexPath
            var scheduleItem : SSScheduleItem?
            let indexPath = sender as! NSIndexPath
            
            //get data for detailVC
            if indexPath.section == 0 {
                //get shift
                if let shifts = self.shiftFetchResultsController.fetchedObjects as? [SSShift] where !shifts.isEmpty {
                    scheduleItem = shifts.first!
                }
            } else {
                if let notes = self.notesFetchResultsController.fetchedObjects as? [SSNote] where !notes.isEmpty {
                    scheduleItem = notes[indexPath.row]
                }
            }

            //create VC to edit schedule
            let scheduleItemVC : ScheduleItemViewController = segue.destinationViewController as! ScheduleItemViewController
            
            //set VC's date to selectedDate, and cast sender as SSTBCellData
            scheduleItemVC.delegate = self
            scheduleItemVC.scheduleItem = scheduleItem
            scheduleItemVC.schedule = self.schedulesDict[self.selectedDate.keyFromDate]
            scheduleItemVC.selectedIndexPath = indexPath
            
        case "scheduleEditVCsegue" :
            
            //create VC to create new schedule
            let scheduleVC : ScheduleEditViewController = segue.destinationViewController as! ScheduleEditViewController
            scheduleVC.delegate = self
            scheduleVC.schedule = sender as! SSSchedule
            
        case "menuSegue" :

            //TODO: FIX VC PRESENTATION
            let menuVC : MenuViewController = segue.destinationViewController as! MenuViewController
            menuVC.user = sender as! SSUser
            menuVC.delegate = self
            
        default :
            self.makeAlert(self, title: "Critical Error : UI", error: nil)
        }
        
    }
    
    //toggles between week and month view
    func weekViewEnabled(flag: Bool) {
        
        //toggle week/month mode and reload
        self.calendarManager.settings.weekModeEnabled = flag
        
        //set calendarView date to selectedDate if not nil, leave the same otherwise
        if let dayForWeekView = self.selectedDate {
            self.calendarView.date = dayForWeekView
        }
        
        //get height of calendarView based on whether or not your in week or month mode, set constraint to height
        let newHeight : CGFloat = flag ? 85 : 300
        self.calendarViewHeight.constant = newHeight
        
        //layout if needed
        self.view.layoutIfNeeded()
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
    
    //fetches schedule at exact date
    func getSchedule(withDate date : NSDate) -> SSSchedule? {
        
        //get schedules from store if they exist
        if let schedules = self.scheduleFetchResultsController.fetchedObjects as? [SSSchedule] where !schedules.isEmpty {
            return schedules.filter({$0.date?.readableDate == date.readableDate}).first
        }

        return nil
    }
    
    //fetch shift and notes from store
    func fetchShiftAndNotes(forSchedule schedule : SSSchedule) {

        //clear out shift and notes cashe
        NSFetchedResultsController.deleteCacheWithName("shiftCalVC")
        NSFetchedResultsController.deleteCacheWithName("notesCalVC")
        
        //configure the predicate and set to the fetchResultControllers
        let predicate = NSPredicate(format: "schedule == %@", schedule)
        self.shiftFetchResultsController.fetchRequest.predicate = predicate
        self.notesFetchResultsController.fetchRequest.predicate = predicate
        
        //perform fetches
        do {
            try self.shiftFetchResultsController.performFetch()
        } catch {
            
            //alert user that app failed to load date
            self.makeAlert(self, title: "Failed to Load Shifts", error: error as NSError)
        }
        do {
            try self.notesFetchResultsController.performFetch()
        } catch {
            
            //alert user that app failed to load date
            self.makeAlert(self, title: "Failed to Load Notes", error: error as NSError)
        }

        //clear out predicates (probably not required, but safe)
        self.shiftFetchResultsController.fetchRequest.predicate = nil
        self.notesFetchResultsController.fetchRequest.predicate = nil
        
    }
    
    //checks if shifts and notes exist for schedule, if they don't, schedule removed from context and cache, returns bool for inidication
    func checkScheduleForRemoval(schedule: SSSchedule) {
        
        //fetch shift and notes
        self.fetchShiftAndNotes(forSchedule: schedule)

        //bool to tell if shift exists or not
        let hasShift : Bool = {
            if let shifts = self.shiftFetchResultsController.fetchedObjects {
                if !shifts.isEmpty {
                    return true
                }
            }
            //shifts is empty, or they don't exist
            return false
        }()
        
        //bool to tell if shift exists or not
        let hasNotes : Bool = {
            if let notes = self.notesFetchResultsController.fetchedObjects {
                if !notes.isEmpty {
                    //notes exist and are not empty
                    return true
                }
            }
            //notes are empty, or they don't exist
            return false
        }()
        
        //if no shift nor notes, return true, else false
        if !hasShift && !hasNotes {
            //no shift or notes, remove from context and cache, save, reconfig UI
            self.schedulesDict.removeValueForKey(self.selectedDate.keyFromDate)
            CoreDataStackManager.sharedInstance().managedObjectContext.deleteObject(schedule)
            self.configUIViews(self.selectedDate)
        }
    }
    
    //convenience method for fetching schedules
    func fetchSchedules() {
        
        //clear out caches
        NSFetchedResultsController.deleteCacheWithName(nil)
        
        //fetch all schedules
        do {
            try self.scheduleFetchResultsController.performFetch()
        } catch {

            //alert user that app failed to load date
            self.makeAlert(self, title: "Failed to Load Schedules", error: error as NSError)
        }
        
        //successful fetch, make temp array of schedules, and map to [String: SSSchedule], set to schedulesDict
        self.schedulesDict = [String : SSSchedule]()
        let schedules = self.scheduleFetchResultsController.fetchedObjects as! [SSSchedule]
        for schedule in schedules {
            self.schedulesDict[schedule.date!.keyFromDate] = schedule
        }
    }
    
    //modally show menuViewController
    func showMenu() {
        //TODO: MAKE SEGUE FROM LEFT IN PRODUCTION
        
        //perform segue
        self.performSegueWithIdentifier("menuSegue", sender: self.user)
    }
    
    //logout button hit in menuVC
    func willLogoutUser(user: SSUser) {
        
        //clear out schedules
        self.schedulesDict = [String : SSSchedule]()
        
        //dismiss VC
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    //called when controllers change content in the context
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        //begin updates if controller is of shift or notes, return otherwise
        if controller == self.shiftFetchResultsController || controller == self.notesFetchResultsController {
            self.dayViewTableView.beginUpdates()
        } else {
            return
        }
        
    }
    
    //updating table depending on which controller changing objects
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        //do nothing if called by scheduleFetchResultsController
        if controller == self.scheduleFetchResultsController {
            return
        }
        
        //will calculate values for indexPaths based on which section and controller is called
        var oldIndexPath : NSIndexPath?
        var newerIndexPath : NSIndexPath?
        
        //configure old index paths based on which controller calls the delegate method
        if let indexPath = indexPath {
            switch controller {
            case self.shiftFetchResultsController :
                oldIndexPath = NSIndexPath(forRow: indexPath.row, inSection: 0)
            case self.notesFetchResultsController :
                oldIndexPath = NSIndexPath(forRow: indexPath.row, inSection: 1)
            default :
                break
            }
        }
        
        //configure new index paths based on which controller calls the delegate method
        if let newIndexPath = newIndexPath {
            switch controller {
            case self.shiftFetchResultsController :
                newerIndexPath = NSIndexPath(forRow: newIndexPath.row, inSection: 0)
            case self.notesFetchResultsController :
                newerIndexPath = NSIndexPath(forRow: newIndexPath.row, inSection: 1)
            default :
                break
            }
        }

        //make changes to table depending on changeType
        switch type {
        case .Insert :
            self.dayViewTableView.insertRowsAtIndexPaths([newerIndexPath!], withRowAnimation: .Fade)
        case .Delete :
            self.dayViewTableView.deleteRowsAtIndexPaths([oldIndexPath!], withRowAnimation: .Fade)
        case .Update :
            var scheduleItem : SSScheduleItem
            if controller == self.shiftFetchResultsController {
                scheduleItem = controller.objectAtIndexPath(oldIndexPath!) as! SSShift
            } else {
                scheduleItem = controller.fetchedObjects![oldIndexPath!.row] as! SSNote
            }
            let cell = self.dayViewTableView.cellForRowAtIndexPath(oldIndexPath!) as! SSTableViewCell
            self.configureCell(cell, withItem: scheduleItem)
        case .Move :
            self.dayViewTableView.deleteRowsAtIndexPaths([oldIndexPath!], withRowAnimation: .Fade)
            self.dayViewTableView.insertRowsAtIndexPaths([newerIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    //called when controllers are finished changing the context
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        //end up tableView updates if called by shift or notes controller, return otherwise
        if controller == self.shiftFetchResultsController || controller == self.notesFetchResultsController {
            self.dayViewTableView.endUpdates()
        } else {
            //if schedule for date still exists, check if it should be removed, configure UI accordingly
            if let schedule = self.schedulesDict[self.selectedDate.keyFromDate] {
                //there is a schedule, check for removal
                self.checkScheduleForRemoval(schedule)
            }
            //reload calendar
            self.calendarManager.reload()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

