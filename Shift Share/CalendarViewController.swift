//
//  CalendarViewController.swift
//  Shift Share
//
//  Created by Brian Josel on 11/12/15.
//  Copyright © 2015 Brian Josel. All rights reserved.
//

import UIKit
import JTCalendar
import Parse
import Foundation
import CoreData

//main calendarView
class CalendarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SSCalendarDelegate, NSFetchedResultsControllerDelegate {
    //TODO: FIX SCHEDULES NEED TO LOAD ONCE SAVED
    //      IMPLEMENT A CACHE
    //calendar manager
    var calendarManager : JTCalendarManager!
    
    //date is selected when a user touches that dayView
    var selectedDate : NSDate! {
        didSet {
            print("setting date to \(self.selectedDate.readableDate)")
            //when date is set, reload table
            self.dayViewTableView.reloadData()
        }
    }

    //outlets
    @IBOutlet weak var monthSelectorView: JTCalendarMenuView!
    @IBOutlet weak var calendarView: JTHorizontalCalendarView!
    @IBOutlet weak var dayViewTableView: UITableView!
    @IBOutlet weak var calendarViewHeight: NSLayoutConstraint!
    @IBOutlet weak var leftSSButton: SSButton!
    @IBOutlet weak var rightSSButton: SSButton!
    
    //fetched results controller
    lazy var scheduleFetchResultsController : NSFetchedResultsController = {
        
        //create fetch request
        let fetchRequest = NSFetchRequest(entityName: "SSSchedule")
        
        //make sort descriptor
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
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
        
        //hide navBar
        self.navigationController?.navigationBar.hidden = true
        
        //reload calendar
//        self.calendarManager.reload()
//        self.calendarView.reloadInputViews()
//        self.dayViewTableView.reloadData()
//        print(self.fetchSchedule(atDate: self.selectedDate))
        print(self.navigationController?.viewControllers)
        
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
        
        //start with today's date
        self.selectedDate = NSDate()
        
        //create random events for testability
        //TODO: DELETE THIS
//        self.createRandomEvents()
//        self.createSetEvents()
        
        //fetchedResultsControllerDelegates
        self.shiftFetchResultsController.delegate = self
        self.notesFetchResultsController.delegate = self
        self.scheduleFetchResultsController.delegate = self
        
        //fetch schedules
        self.fetchSchedules()
        
        //setup views
        self.calendarManager.menuView = self.monthSelectorView
        self.calendarManager.contentView = self.calendarView
        self.calendarManager.setDate(NSDate())
        self.leftSSButton.hostViewController = self
        self.rightSSButton.hostViewController = self
        self.leftSSButton.ssButtonType = {
            //load button to be NEW if a schedule does not exist, or EDIT if it does
            if let _ = self.getSchedule(withDate: self.selectedDate) {
                return .EDIT
            }
            return .NEW
        }()
        self.rightSSButton.ssButtonType = .TODAY
        self.monthSelectorView.bringSubviewToFront(self.leftSSButton)
        self.monthSelectorView.bringSubviewToFront(self.rightSSButton)
        self.dayViewTableView.allowsMultipleSelectionDuringEditing = false

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
            //failed to cast, abort
            //TODO: REMOVE IN PRODUCTION
            abort()
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
        
        //set image and dotViews accordingly if shift or notes exist
        guard let schedule = self.getSchedule(withDate: dayView.date) else {
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
    
    //code for handling touching the dayView of the calendar
    func calendar(calendar: JTCalendarManager!, didTouchDayView dayView: UIView!) {
        
        //cast dayView to ShiftShareDayView
        guard let dayView = dayView as? SSDayView else {
            //failed to cast, abort
            //TODO: REMOVE IN PRODUCTION
            abort()
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
        
        //get schedule if it exists
        guard let schedule = self.getSchedule(withDate: self.selectedDate) else {
            
            //no schedule, change button type to new and exist routine
            self.leftSSButton.ssButtonType = SSButtonType.NEW
            return
        }
        
        //schedule exits, fetch shifts and notes and set button
        self.fetchShiftAndNotes(forSchedule: schedule)
        self.leftSSButton.ssButtonType = SSButtonType.EDIT

    }
    
    //handles double taps of dayViews
    func calendar(calendar: JTCalendarManager!, didDoubleTapDayView dayView: UIView!) {
        
        //cast dayView to ShiftShareDayView
        guard let _ = dayView as? SSDayView else {
            //failed to cast, abort
            //TODO: REMOVE IN PRODUCTION
            abort()
        }
        
        //toggle weekView
        self.weekViewEnabled(!self.calendarManager.settings.weekModeEnabled)
        
        //reload table data
        self.dayViewTableView.reloadData()
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
            
            let newSchedule = SSSchedule(forDate: (self.selectedDate), forUser: "Brian", context: CoreDataStackManager.sharedInstance().managedObjectContext)
            
            //segue to scheduleEditVC only
            self.performSegueWithIdentifier("scheduleEditVCsegue", sender: newSchedule)
            
            
        case .EDIT :
            
            let scheduleToEdit = self.getSchedule(withDate: self.selectedDate)
            
            //segue to VC to create schedule
            self.performSegueWithIdentifier("scheduleEditVCsegue", sender: scheduleToEdit)
            
        case .DONE :        //TODO: REMOVE???
            //commit changes
            //TODO: MAKE METHOD TO SAVE CHANGES
            
            //go back to month view
            self.weekViewEnabled(false)

        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        //if no schedule, one section, if there is, compute
        guard let schedule = self.getSchedule(withDate: self.selectedDate) else {
            return 1
        }
        print(schedule.date?.readableDate)
        //two sections, one for shift, one for notes
        return 2
    }
    
    //number of rows in tableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //get dayView and schedule if they exist, return 1 or 2 otherwise
        guard let schedule = self.getSchedule(withDate: self.selectedDate) else {
            
            //no schedule
            return 1
        }
        
        print(schedule.date?.readableDate)
        
        if section == 0 {
            return self.shiftFetchResultsController.fetchedObjects!.count
        } else {
            return self.notesFetchResultsController.fetchedObjects!.count
        }
    }
    
    //cell alpha values depending on schedule present or not
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        //check if schedule exists for date
        guard let schedule = self.getSchedule(withDate: self.selectedDate) else {
            //no schedule, gray out
            cell.alpha = 0.5
            
            //scroll disabled
            tableView.userInteractionEnabled = false
            tableView.scrollEnabled = false
            return
        }
        
            print(schedule.date?.readableDate)
            //schedule exists, full color
            cell.alpha = 1.0
            
            //scroll enabled
            tableView.userInteractionEnabled = true
            tableView.scrollEnabled = true
    }
    
    //creates cells for tableView
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        //create cell
        guard let cell = tableView.dequeueReusableCellWithIdentifier("SSTableViewCell") as? SSTableViewCell else {
            print("no cell made")
            self.navigationController?.popToRootViewControllerAnimated(true)
            return UITableViewCell()
        }
        
        //if there is a schedule, proceed, else
        guard let _ = self.getSchedule(withDate: self.selectedDate) else {
            //create scratch shift
            let newShift = SSShift(type: nil, context: CoreDataStackManager.sharedInstance().scratchContext)
            newShift.title = "No Schedule"
            self.configureCell(cell, withItem: newShift)
            return cell
        }
        
        if indexPath.section == 0 {
            if let shifts = self.shiftFetchResultsController.fetchedObjects where shifts.count != 0, let shift = shifts[indexPath.row] as? SSShift {
                print(shift)
                print(shift.type)
                self.configureCell(cell, withItem: shift)
            }
        } else {
            if let notes = self.notesFetchResultsController.fetchedObjects where notes.count != 0, let note = notes[indexPath.row] as? SSNote {
                self.configureCell(cell, withItem: note)
            }
        }
        
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
                let shift = self.shiftFetchResultsController.objectAtIndexPath(indexPath) as! SSShift
                CoreDataStackManager.sharedInstance().managedObjectContext.deleteObject(shift)
                CoreDataStackManager.sharedInstance().saveContext()
            } else {
                //object is note
                let note = self.notesFetchResultsController.objectAtIndexPath(indexPath) as! SSNote
                CoreDataStackManager.sharedInstance().managedObjectContext.deleteObject(note)
                CoreDataStackManager.sharedInstance().saveContext()
            }
        }
    }
    
    //handles segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
        if segue.identifier == "TBeditVCSegueFromCal" {
            
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
            let tbEditVC : TBDataEditViewController = segue.destinationViewController as! TBDataEditViewController
            
            //set VC's date to selectedDate, and cast sender as SSTBCellData
            tbEditVC.scheduleItem = scheduleItem
            tbEditVC.schedule = self.getSchedule(withDate: self.selectedDate)
            tbEditVC.selectedIndexPath = indexPath
            
        } else if segue.identifier == "scheduleEditVCsegue" {
            
            //create VC to create new schedule
            let scheduleVC : ScheduleEditViewController = segue.destinationViewController as! ScheduleEditViewController
            scheduleVC.schedule = sender as! SSSchedule
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
        
//        if let shifts = self.shiftFetchResultsController.fetchedObjects, let notes = self.notesFetchResultsController.fetchedObjects {
//            
//            if !shifts.isEmpty || !notes.isEmpty {
//                print("clearing cache failing")
//                print("shifts count = \(shifts.count)")
//                print("notes.count = \(notes.count)")
//                abort()
//            }
//        }
        
        //configure the predicate and set to the fetchResultControllers
        let predicate = NSPredicate(format: "schedule == %@", schedule)
        self.shiftFetchResultsController.fetchRequest.predicate = predicate
        self.notesFetchResultsController.fetchRequest.predicate = predicate
        
        //perform fetches
        do {
            try self.shiftFetchResultsController.performFetch()
        } catch {
            //TODO: HANDLE ERROR
            print("FAILED TO FETCH SHIFTS")
        }
        do {
            try self.notesFetchResultsController.performFetch()
        } catch {
            //TODO: HANDLE ERROR
            print("FAILED TO FETCH NOTES")
        }
        
        //clear out predicates (probably not required, but safe)
        self.shiftFetchResultsController.fetchRequest.predicate = nil
        self.notesFetchResultsController.fetchRequest.predicate = nil
        
    }
    
    //convenience method for fetching schedules
    func fetchSchedules() {
        
        //clear out caches
        NSFetchedResultsController.deleteCacheWithName(nil)
        
        //fetch all schedules
        do {
            try self.scheduleFetchResultsController.performFetch()
        } catch {
            //TODO: HANDLE ERROR
            print("fetching schedules failed")
        }
    }
    
    //called when controllers change content in the context
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
//        if controller == self.shiftFetchResultsController || controller == self.notesFetchResultsController {
//            self.dayViewTableView.beginUpdates()
//        }
        
    }
    
    //
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
//        if controller == self.shiftFetchResultsController || controller == self.notesFetchResultsController {
////            self.dayViewTableView.endUpdates()
//        } else {
//        
//            self.fetchSchedules()
//            self.calendarManager.reload()
//        }
    }
    
    
//    //returns bool if an event is scheduled for that day
//    func haveEventForThatDay(date: NSDate) -> Bool {
//        
//        //check if there is an event for the key
//        guard let _ = SSSchedule.sharedInstance().schedules[date.keyFromDate] else {
//            
//            //no key for that date
//            return false
//        }
//
//        //events exist on this date
//        return true
//        
//    }
    
    //test function
    //TODO: DELETE THIS
//    func createSetEvents() {
//        
//        let dateFormatter = NSDateFormatter()
//        dateFormatter.dateFormat = "dd-MM-yyyy"
//        
//        let key1 = "06-12-2015"
//        let key2 = "13-12-2015"
//        let key3 = "20-12-2015"
//        let key4 = "27-12-2015"
//        let key5 = "14-12-2015"
//        let key6 = "03-01-2016"
//        let key7 = "30-12-2015"
//        let key8 = "24-12-2015"
//        
//        let note1 = SSNote(title: "Schedule 1", body: key1)
//        let note2 = SSNote(title: "Schedule 2", body: key2)
//        let note3 = SSNote(title: "Schedule 3", body: key3)
//        let note4 = SSNote(title: "Schedule 4", body: key4)
//        let note5 = SSNote(title: "Schedule 5", body: key5)
//        let note6a = SSNote(title: "Schedule 6a", body: key6)
//        let note6b = SSNote(title: "Schedule 6b", body: nil)
//        let note8 = SSNote(title: "Schedule 8", body: key8)
//        
//        guard let date1 = dateFormatter.dateFromString(key1),
//            let date2 = dateFormatter.dateFromString(key2),
//            let date3 = dateFormatter.dateFromString(key3),
//            let date4 = dateFormatter.dateFromString(key4),
//            let date5 = dateFormatter.dateFromString(key5),
//            let date6 = dateFormatter.dateFromString(key6),
//            let date7 = dateFormatter.dateFromString(key7),
//            let date8 = dateFormatter.dateFromString(key8)
//        else {
//            print("no events set")
//            return
//        }
//    
//        SSSchedule.sharedInstance().schedules = [
//            date1.keyFromDate : SSSchedule(forDate: date1, withShift: SSShift(type: .DAY), withNotes: [note1], forUser: "Brian"),
//            date2.keyFromDate : SSSchedule(forDate: date2, withShift: SSShift(type: .NIGHT), withNotes: [note2], forUser: "Brian"),
//            date3.keyFromDate : SSSchedule(forDate: date3, withShift: SSShift(type: .NIGHT), withNotes: [note3], forUser: "Brian"),
//            date4.keyFromDate : SSSchedule(forDate: date4, withShift: SSShift(type: .DAY), withNotes: [note4], forUser: "Brian"),
//            date5.keyFromDate : SSSchedule(forDate: date5, withShift: SSShift(type: .DAY), withNotes: [note5], forUser: "Brian"),
//            date6.keyFromDate : SSSchedule(forDate: date6, withShift: SSShift(type: .NIGHT), withNotes: [note6a, note6b], forUser: "Brian"),
//            date7.keyFromDate : SSSchedule(forDate: date7, withShift: SSShift(type: .VACATION), withNotes: nil, forUser: "Brian"),
//            date8.keyFromDate : SSSchedule(forDate: date8, withShift: nil, withNotes: [note8], forUser: "Brian")
//        ]
//        
//        for (_, schedule) in SSSchedule.sharedInstance().schedules {
//            schedule.manager = self.scheduleManager
//        }
//    }
    
    //test function
    //TODO: DELETE THIS
//    func createRandomEvents() {
//        
//        for var i = 0; i < 30; i++ {
//            
//            //create random date from today
//            let today = NSDate()
//            let mod = Int32(3600 * 24 * 60)
//            let randomNum = arc4random()
//            let intervalNum = randomNum % UInt32(mod)
//            let intervalNumDouble = Double(intervalNum)
//            let interval = NSTimeInterval.abs(intervalNumDouble)
//            let randomDate = NSDate(timeInterval: interval, sinceDate: today)
//            
//            //create random shift
//            let rawVal = Int(randomNum % 7)
//            let shift : SSShift? = (rawVal <= 5) ? SSShift(type: SSShiftType(rawValue: rawVal)!) : nil
//            
//            //create notes for the day
//            let count = Int(randomNum % 6)
//            var notes : [SSNote] = []
//            for var j = 0; j < count; j++ {
//                let note = SSNote(title: "Note\(j)", body: "Body\(j)")
//                notes.append(note)
//            }
//            
//            //make schedule from shift and notes
//            if notes.count != 0 || shift != nil {
//                
//                let schedule = SSSchedule(forDate: randomDate, withShift: shift, withNotes: notes, forUser: "Brian")
//                schedule.manager = self.scheduleManager
//                if SSSchedule.sharedInstance().schedules[randomDate.keyFromDate] == nil {
//                    SSSchedule.sharedInstance().schedules[randomDate.keyFromDate] = schedule
//                }
//            }
//            
//        }
//    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

