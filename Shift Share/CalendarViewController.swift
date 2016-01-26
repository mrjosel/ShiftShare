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

//main calendarView
class CalendarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SSCalendarDelegate {

    //calendar manager
    var calendarManager : JTCalendarManager!
    
    //schedule manager
    var scheduleManager : SSScheduleManager!
    
    //date is selected when a user touches that dayView
    var selectedDate : NSDate!
    
    //locale for use in displaying date formats
    //TODO: IMPLEMENT THIS
    var locale : String?

    //outlets
    @IBOutlet weak var monthSelectorView: JTCalendarMenuView!
    @IBOutlet weak var calendarView: JTHorizontalCalendarView!
    @IBOutlet weak var dayViewTableView: UITableView!
    @IBOutlet weak var calendarViewHeight: NSLayoutConstraint!
    @IBOutlet weak var leftSSButton: SSButton!
    @IBOutlet weak var rightSSButton: SSButton!
    
    //do anytime view will show
    override func viewWillAppear(animated: Bool) {
        
        //hide navBar
        self.navigationController?.navigationBar.hidden = true
        
        //reload calendar
        self.calendarManager.reload()
        self.calendarView.reloadInputViews()
        self.dayViewTableView.reloadData()
        
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
        
        //create schedule manager, when schedules are created, set schedules manager var to this
        self.scheduleManager = SSScheduleManager()
        
        //start with today's date
        self.selectedDate = NSDate()
        
        //create random events for testability
        //TODO: DELETE THIS
        self.createRandomEvents()
//        self.createSetEvents()
        
        //setup views
        self.calendarManager.menuView = self.monthSelectorView
        self.calendarManager.contentView = self.calendarView
        self.calendarManager.setDate(NSDate())
        self.locale = NSLocale.currentLocale().localeIdentifier
        self.leftSSButton.hostViewController = self
        self.rightSSButton.hostViewController = self
        self.leftSSButton.ssButtonType = .NEW
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
        guard let schedule = SSSchedule.sharedInstance().schedules[dayView.date.keyFromDate] else {
            //no schedule, keep defaults
            //NOTE: This is likely redundant (the following two params are hidden by default,
            //      but it fixes a bug in the JTCalendar Framework where dayViews without schedules have shift images
            //      and dotViews displayed.  The JTCalendar example project has a similar method in its viewController.
            dayView.dotView.hidden = true
            dayView.ssDVImageView.hidden = true
            return
        }
        
        //set image
        dispatch_async(dispatch_get_main_queue(), {
            dayView.ssDVImageView.image = schedule.shift?.image
            dayView.ssDVImageView.hidden = (dayView.ssDVImageView.image == nil)
        })
        
        //display dotView if notes exist
        if let notes = schedule.notes where notes.count != 0 {
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
        case .NEW :
            
            self.performSegueWithIdentifier("newVCsegue", sender: self.selectedDate)
            
//            //present editVC, if no date is selected then present for today's date
//            if let date = self.selectedDate {
//                self.presentNewScheduleVC(forDate: date)
//            } else {
//                self.presentNewScheduleVC(forDate: NSDate())
//            }
            
        case .CANCEL :
            //discard changes in scheduleEdit mode
            //TODO: DISCARD ALL CHANGES
            
            //go back to month view
            self.weekViewEnabled(false)
            
        case .DONE :
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
        guard let schedule = SSSchedule.sharedInstance().schedules[self.selectedDate!.keyFromDate] else {
            
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
        if let _ = SSSchedule.sharedInstance().schedules[self.selectedDate.keyFromDate] {
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
        guard let cell = tableView.dequeueReusableCellWithIdentifier("SSTableViewCell") as? SSTableViewCell,
        date = self.selectedDate else {
            print("no cell made")
            return UITableViewCell()
        }
        
        //set date in cell (for bookkeeping, may be removed later)
        cell.date = date
        
        //get data to populate cells
        var tableData : [SSTBCellData] = []
        
        if let schedule = SSSchedule.sharedInstance().schedules[date.keyFromDate] {
            
            //get tableData
            tableData = schedule.tableData
            
        } else {
            
            //create table data based on edit mode or not
            tableData = SSSchedule.emptyTableData()
            
        }
        
        //get cellData from tableData
        let cellData = tableData[indexPath.row]
        
        //set cell properties
        cell.imageView?.image = cellData.image
        cell.textLabel?.text = cellData.title
        cell.detailTextLabel?.text = cellData.body
        
        return cell
    }
    
    //tapping cells launches detail view or launches edit mode if selected while in edit mode
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //get schedule for date corresponding to selected cell
        guard let schedule = SSSchedule.sharedInstance().schedules[self.selectedDate.keyFromDate] else {
            
            //no schedule, add shifts, notes
            return
        }
        
        //get data for detailVC
        let cellData = schedule.tableData[indexPath.row]
        
        //perform segue to editVC
        self.performSegueWithIdentifier("editVCSegueFromCal", sender: cellData)
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
            
            //get schedule
            let schedule = SSSchedule.sharedInstance().schedules[self.selectedDate.keyFromDate]
            
            //get tableData
            let data = schedule?.tableData[indexPath.row]
            
            //determine if data is shift or is note
            if let _ = data as? SSShift {

                //data is shift, set shift in schedule to nil
                schedule?.shift = nil
                
            } else if let _ = data as? SSNote {

                //data is note, remove from notes array (index has to be minus 1 if shift exists
                if let _ = schedule?.shift {
                    schedule?.notes?.removeAtIndex(indexPath.row - 1)
                } else {
                    schedule?.notes?.removeAtIndex(indexPath.row)
                }
            }
            
            //reload calendar and table
            self.calendarManager.reload()
            self.dayViewTableView.reloadData()
        }
    }
    
    //handles segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "editVCSegueFromCal" {

            //create VC to edit schedule
            let scheduleDetailVC : ScheduleEditViewController = segue.destinationViewController as! ScheduleEditViewController
            
            //set VC's date to selectedDate, and cast sender as SSTBCellData
            scheduleDetailVC.userSelectedData = sender as? SSTBCellData
            scheduleDetailVC.date = self.selectedDate
            
        } else if segue.identifier == "newVCsegue" {
            
            //create VC to create new schedule
            let newScheduleVC : NewScheduleViewController = segue.destinationViewController as! NewScheduleViewController
            
            //set VC's date accordingly
            newScheduleVC.date = sender as? NSDate
        }
        
    }
    
    //presents editVC
    func presentNewScheduleVC(forDate date: NSDate) {

        if SSSchedule.sharedInstance().schedules[self.selectedDate.keyFromDate] != nil {
            //TODO: ALERT FUNCTION TO DELETE SCHEDULE
            print("delete schedule?")
            return
        }
        
        //create VC for modal presentation
        let newScheduleVC = self.storyboard?.instantiateViewControllerWithIdentifier("NewScheduleViewController") as! NewScheduleViewController
        
        //send date to new VC
        newScheduleVC.date = self.selectedDate
        
        //set VC's schedule to schedule, and present
        self.presentViewController(newScheduleVC, animated: true, completion: nil)
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
    func createSetEvents() {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        let key1 = "06-12-2015"
        let key2 = "13-12-2015"
        let key3 = "20-12-2015"
        let key4 = "27-12-2015"
        let key5 = "14-12-2015"
        let key6 = "03-01-2016"
        let key7 = "30-12-2015"
        let key8 = "24-12-2015"
        
        let note1 = SSNote(title: "Schedule 1", body: key1)
        let note2 = SSNote(title: "Schedule 2", body: key2)
        let note3 = SSNote(title: "Schedule 3", body: key3)
        let note4 = SSNote(title: "Schedule 4", body: key4)
        let note5 = SSNote(title: "Schedule 5", body: key5)
        let note6a = SSNote(title: "Schedule 6a", body: key6)
        let note6b = SSNote(title: "Schedule 6b", body: nil)
        let note8 = SSNote(title: "Schedule 8", body: key8)
        
        guard let date1 = dateFormatter.dateFromString(key1),
            let date2 = dateFormatter.dateFromString(key2),
            let date3 = dateFormatter.dateFromString(key3),
            let date4 = dateFormatter.dateFromString(key4),
            let date5 = dateFormatter.dateFromString(key5),
            let date6 = dateFormatter.dateFromString(key6),
            let date7 = dateFormatter.dateFromString(key7),
            let date8 = dateFormatter.dateFromString(key8)
        else {
            print("no events set")
            return
        }
    
        SSSchedule.sharedInstance().schedules = [
            date1.keyFromDate : SSSchedule(forDate: date1, withShift: SSShift(type: .DAY), withNotes: [note1], forUser: "Brian"),
            date2.keyFromDate : SSSchedule(forDate: date2, withShift: SSShift(type: .NIGHT), withNotes: [note2], forUser: "Brian"),
            date3.keyFromDate : SSSchedule(forDate: date3, withShift: SSShift(type: .NIGHT), withNotes: [note3], forUser: "Brian"),
            date4.keyFromDate : SSSchedule(forDate: date4, withShift: SSShift(type: .DAY), withNotes: [note4], forUser: "Brian"),
            date5.keyFromDate : SSSchedule(forDate: date5, withShift: SSShift(type: .DAY), withNotes: [note5], forUser: "Brian"),
            date6.keyFromDate : SSSchedule(forDate: date6, withShift: SSShift(type: .NIGHT), withNotes: [note6a, note6b], forUser: "Brian"),
            date7.keyFromDate : SSSchedule(forDate: date7, withShift: SSShift(type: .VACATION), withNotes: nil, forUser: "Brian"),
            date8.keyFromDate : SSSchedule(forDate: date8, withShift: nil, withNotes: [note8], forUser: "Brian")
        ]
        
        for (_, schedule) in SSSchedule.sharedInstance().schedules {
            schedule.manager = self.scheduleManager
        }
    }
    
    //test function
    //TODO: DELETE THIS
    func createRandomEvents() {
        
        for var i = 0; i < 30; i++ {
            
            //create random date from today
            let today = NSDate()
            let mod = Int32(3600 * 24 * 60)
            let randomNum = arc4random()
            let intervalNum = randomNum % UInt32(mod)
            let intervalNumDouble = Double(intervalNum)
            let interval = NSTimeInterval.abs(intervalNumDouble)
            let randomDate = NSDate(timeInterval: interval, sinceDate: today)
            
            //create random shift
            let rawVal = Int(randomNum % 7)
            let shift : SSShift? = (rawVal <= 5) ? SSShift(type: SSShiftType(rawValue: rawVal)!) : nil
            
            //create notes for the day
            let count = Int(randomNum % 6)
            var notes : [SSNote] = []
            for var j = 0; j < count; j++ {
                let note = SSNote(title: "Note\(j)", body: "Body\(j)")
                notes.append(note)
            }
            
            //make schedule from shift and notes
            if notes.count != 0 || shift != nil {
                
                let schedule = SSSchedule(forDate: randomDate, withShift: shift, withNotes: notes, forUser: "Brian")
                schedule.manager = self.scheduleManager
                if SSSchedule.sharedInstance().schedules[randomDate.keyFromDate] == nil {
                    SSSchedule.sharedInstance().schedules[randomDate.keyFromDate] = schedule
                }
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

