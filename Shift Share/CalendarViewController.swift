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

    //calendar manager
    var calendarManager : JTCalendarManager!
    
    //date is selected when a user touches that dayView
    var selectedDate : NSDate!

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
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStackManager.sharedInstance().managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
    
    lazy var shiftFetchResultsController : NSFetchedResultsController = {
        
        //create fetch request
        let fetchRequest = NSFetchRequest(entityName: "SSShift")
        
        //make sort descriptor
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        //create controller and return
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStackManager.sharedInstance().managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
    
    lazy var notesFetchResultsController : NSFetchedResultsController = {
        
        //create fetch request
        let fetchRequest = NSFetchRequest(entityName: "SSNote")
        
        //make sort descriptor
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: true)]
        
        //create controller and return
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStackManager.sharedInstance().managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
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
        
        //perform fetch
        do {
            try self.scheduleFetchResultsController.performFetch()
        } catch {
            //TODO: HANDLE ERROR
            print("failed to fetch schedules")
        }
        
//        print(self.scheduleFetchResultsController.fetchedObjects)
        
        
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
        
        //setup views
        self.calendarManager.menuView = self.monthSelectorView
        self.calendarManager.contentView = self.calendarView
        self.calendarManager.setDate(NSDate())
        self.leftSSButton.hostViewController = self
        self.rightSSButton.hostViewController = self
        self.leftSSButton.ssButtonType = .NEW
        self.rightSSButton.ssButtonType = .TODAY
        self.monthSelectorView.bringSubviewToFront(self.leftSSButton)
        self.monthSelectorView.bringSubviewToFront(self.rightSSButton)
        self.dayViewTableView.allowsMultipleSelectionDuringEditing = false
        
        //fetchedResultsControllerDelegate
//        self.scheduleFetchResultsController.delegate = self
        self.shiftFetchResultsController.delegate = self
        self.notesFetchResultsController.delegate = self
        
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
        
        
        if dayView.date.readableDate == "February 14, 2016" {
            //catch debug
            
            
            print("da fourteemff")
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
        
        //first configure predicate
        self.scheduleFetchResultsController.fetchRequest.predicate = NSPredicate(format: "date == %@", dayView.date)
            do {
                try self.scheduleFetchResultsController.performFetch()
            } catch {
                //TODO: HANDLE ERROR
                print("fetching schedules failed")
            }
        
//        print(self.scheduleFetchResultsController.fetchedObjects)
        
        //set image and dotViews accordingly if shift or notes exist
        guard let schedule = self.scheduleFetchResultsController.fetchedObjects?.first as? SSSchedule else {
            //no schedule, keep defaults
            //NOTE: This is likely redundant (the following two params are hidden by default,
            //      but it fixes a bug in the JTCalendar Framework where dayViews without schedules have shift images
            //      and dotViews displayed.  The JTCalendar example project has a similar method in its viewController.
            dayView.dotView.hidden = true
            dayView.ssDVImageView.hidden = true
            return
        }
        
        //fetch shift and notes since schedule fetch produced a result
        self.shiftFetchResultsController.fetchRequest.predicate = NSPredicate(format: "schedule == %@", schedule)
        do {
            try self.shiftFetchResultsController.performFetch()
        } catch {
            //TODO: HANDLE ERROR
            print("failed to fetch shift")
        }
        
        self.notesFetchResultsController.fetchRequest.predicate = NSPredicate(format: "schedule == %@", schedule)
        do {
            try self.notesFetchResultsController.performFetch()
        } catch {
            //TODO: HANDLE ERROR
            print("failed to fetch shift")
        }
        
        //set image
        dispatch_async(dispatch_get_main_queue(), {
            if let shift = self.shiftFetchResultsController.fetchedObjects?.first as? SSShift, imageName = shift.imageName {
                dayView.ssDVImageView.image = UIImage(named: imageName)
                dayView.ssDVImageView.hidden = false
            } else {
                dayView.ssDVImageView.image = nil
                dayView.ssDVImageView.hidden = true
            }
        })
        
        //display dotView if notes exist
        if let notes = self.notesFetchResultsController.fetchedObjects where notes.count != 0 {
            dispatch_async(dispatch_get_main_queue(), {
                dayView.dotView.hidden = false
            })
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                dayView.dotView.hidden = true
            })
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

        //set selected date
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
        
        //config button if schedule exists or not
        //TODO: IMPLEMENT WITH FETCH
//        if let _ = SSSchedule.sharedInstance().schedules[self.selectedDate.keyFromDate] {
//            self.leftSSButton.ssButtonType = SSButtonType.EDIT
//        } else {
//            self.leftSSButton.ssButtonType = SSButtonType.NEW
//        }
        
        //reload tableViews
        self.dayViewTableView.reloadData()

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
            self.dayViewTableView.reloadData()
            
            //Edit Button
        case .NEW : //TODO:  CONSOLODATE???
            
            //segue to scheduleEditVC only
            self.performSegueWithIdentifier("scheduleEditVCsegue", sender: self.selectedDate)
            
            
        case .EDIT :
            
            //segue to VC to create schedule
            self.performSegueWithIdentifier("scheduleEditVCsegue", sender: self.selectedDate)
            
        case .DONE :        //TODO: REMOVE???
            //commit changes
            //TODO: MAKE METHOD TO SAVE CHANGES
            
            //go back to month view
            self.weekViewEnabled(false)

        }
        
        //reload table data if applicable
        self.dayViewTableView.reloadData()
    }
    
    //number of rows in tableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //get dayView and schedule if they exist, return 1 or 2 otherwise
        guard let schedule = self.scheduleFetchResultsController.fetchedObjects?.first as? SSSchedule else {
            
            //scroll and cell selection based
            tableView.userInteractionEnabled = false
            return 1
        }
        
        //schedule exists, scroll enabled
        tableView.userInteractionEnabled = true
        tableView.scrollEnabled = true
        
        //tableView not grayed out and is user accessible
        tableView.alpha = 1.0
        
        //number of rows equal to shift plus number of notes
        let cellCount = schedule.tableData.count
        
        //return cellCount
        return cellCount

    }
    
    //cell alpha values depending on schedule present or not
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        //check if schedule exists for date
        if let _ = self.scheduleFetchResultsController.fetchedObjects?.first as? SSSchedule {
            //schedule exists, full color
            cell.alpha = 1.0
        } else {
            //no schedule, gray out
            cell.alpha = 0.5
        }
    }
    
    //creates cells for tableView
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        //create cell
        guard let cell = tableView.dequeueReusableCellWithIdentifier("SSTableViewCell") as? SSTableViewCell else {
            print("no cell made")
            self.navigationController?.popToRootViewControllerAnimated(true)
            return UITableViewCell()
        }
        
        if indexPath.section == 0 {
            if let shifts = self.shiftFetchResultsController.fetchedObjects where shifts.count != 0, let shift = shifts[indexPath.row] as? SSShift {
                
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
    
    //tapping cells launches detail view or launches edit mode if selected while in edit mode
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //get schedule for date corresponding to selected cell
        guard let schedule = self.scheduleFetchResultsController.fetchedObjects?.first as? SSSchedule else {
            
            //no schedule, add shifts, notes
            return
        }
        
        //get data for detailVC
        let cellData = schedule.tableData[indexPath.row]
        
        //perform segue to editVC
        self.performSegueWithIdentifier("TBeditVCSegueFromCal", sender: cellData)
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
    
    
    //allow editing
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

            //create VC to edit schedule
            let tbEditVC : TBDataEditViewController = segue.destinationViewController as! TBDataEditViewController
            
            //set VC's date to selectedDate, and cast sender as SSTBCellData
            tbEditVC.scheduleItem = sender as? SSScheduleItem
            tbEditVC.date = self.selectedDate
            
        } else if segue.identifier == "scheduleEditVCsegue" {
            
            //create VC to create new schedule
            let scheduleVC : ScheduleEditViewController = segue.destinationViewController as! ScheduleEditViewController
            
            //set VC's date accordingly
            scheduleVC.date = sender as? NSDate
            
            //if no schedule exists for date create new schedule and pass on to VC (NOTE: schedule could be cleared in next VC if user cancels)
            var schedule : SSSchedule!
            
            if let scheduleToEdit = self.scheduleFetchResultsController.fetchedObjects?.first as? SSSchedule where scheduleToEdit.date == self.selectedDate  {
                schedule = scheduleToEdit
            } else {
                schedule = SSSchedule(forDate: (sender as? NSDate), forUser: "Brian", context: CoreDataStackManager.sharedInstance().managedObjectContext)
            }
            
            //pass to next VC
            scheduleVC.schedule = schedule

        }
        
    }
    
    //presents editVC
    func presentScheduleEditVC(forDate date: NSDate) {

//        if SSSchedule.sharedInstance().schedules[self.selectedDate.keyFromDate] != nil {
//            //TODO: ALERT FUNCTION TO DELETE SCHEDULE
//            print("delete schedule?")
//            return
//        }
        
        //create VC for modal presentation
        let scheduleEditVC = self.storyboard?.instantiateViewControllerWithIdentifier("ScheduleEditViewController") as! ScheduleEditViewController
        
        //send date to new VC
        scheduleEditVC.date = self.selectedDate
        
        //set VC's schedule to schedule, and present
        self.presentViewController(scheduleEditVC, animated: true, completion: nil)
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
        
        //set date in cell (for bookkeeping, may be removed later)
        cell.date = self.selectedDate
        
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

