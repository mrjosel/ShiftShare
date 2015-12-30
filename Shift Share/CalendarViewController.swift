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
    
//    //vars for logging events in calendar
//    var eventsByDate : NSMutableDictionary?
    
    //calendar manager
    var calendarManager : JTCalendarManager!
    
    //date formatter
    let dateFormatter = NSDateFormatter()
    
    //date is selected when a user touches that dayView
    var selectedDate : NSDate?
    
    //locale for use in displaying date formats
    var locale : String?
    
    //tableView Data
    //TODO: REPLACE WITH CORE DATA
    var tableData : [SSTBCellData]?

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
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
                
        //delegate and dataSource for tableView
        self.dayViewTableView.delegate = self
        self.dayViewTableView.dataSource = self
        
        //set up date formatter
        self.dateFormatter.dateFormat = "dd-MM-yyyy"
        
        //create calendar manager, set vc to calendar manager delegate
        self.calendarManager = JTCalendarManager()
        self.calendarManager.delegate = self
        
        //start with today's date
        self.selectedDate = NSDate()
        
        //create random events for testability
        //TODO: DELETE THIS
        self.createRandomEvents()
//        self.createAllMonthEvents()
//        self.createSetEvents()
        
        //setup views
        self.calendarManager.menuView = self.monthSelectorView
        self.calendarManager.contentView = self.calendarView
        self.calendarManager.setDate(NSDate())
        self.locale = NSLocale.currentLocale().localeIdentifier
        self.leftSSButton.hostViewController = self
        self.rightSSButton.hostViewController = self
        self.leftSSButton.ssButtonType = .EDIT
        self.rightSSButton.ssButtonType = .TODAY
        self.monthSelectorView.bringSubviewToFront(self.leftSSButton)
        self.monthSelectorView.bringSubviewToFront(self.rightSSButton)
        
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

        //if event for that date exists, set image in view
        let key = self.dateFormatter.stringFromDate(dayView.date)
        if let schedule = SSSchedule.sharedInstance().schedules[key], image = schedule.shift?.image {
                dispatch_async(dispatch_get_main_queue(), {
                    dayView.ssDVImageView.image = image
                })
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
        
        //check if there is an event set for that day
        dayView.dotView.hidden = !self.haveEventForThatDay(dayView.date)
        dayView.ssDVImageView.hidden = !self.haveEventForThatDay(dayView.date)
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
        case .EDIT :
            
            //present editVC, if no date is selected then present for today's date
            if let date = self.selectedDate {
                self.presentEditVC(forDate: date)
            } else {
                self.presentEditVC(forDate: NSDate())
            }
            
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
        guard let schedule = self.getScheduleForDate(self.selectedDate) else {
            
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
        if let _ = self.getScheduleForDate(self.selectedDate) {
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
        
        if let schedule = self.getScheduleForDate(self.selectedDate) {
            
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
        guard let schedule = self.getScheduleForDate(self.selectedDate) else {
            
            //no schedule, add shifts, notes
            return
        }
        
        //get data for detailVC
        let cellData = schedule.tableData[indexPath.row]
        
        //perform segue to detailVC
        self.performSegueWithIdentifier("detailVCSegue", sender: cellData)
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
    
    //handles segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "detailVCSegue" {

            //create VC for show presentation
            let scheduleDetailVC : ScheduleDetailViewController = segue.destinationViewController as! ScheduleDetailViewController
            
            //set VC's userData to cellData (sender)
            scheduleDetailVC.userSelectedData = sender as? SSTBCellData
            scheduleDetailVC.date = self.selectedDate
            
        }
        
    }
    
    //presents editVC
    func presentEditVC(forDate date: NSDate) {

        //create VC for modal presentation
        let scheduleEditVC = self.storyboard?.instantiateViewControllerWithIdentifier("ScheduleEditViewController") as! ScheduleEditViewController
        
        //get schedule
        let schedule = self.getScheduleForDate(date)
        
        //set VC's schedule to schedule, and present
        scheduleEditVC.schedule = schedule
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
    
    //returns bool if an event is scheduled for that day
    func haveEventForThatDay(date: NSDate) -> Bool {
        
        //setup key for date
        let key = self.dateFormatter.stringFromDate(date)
        
        //check if there is an event for the key
        guard let _ = SSSchedule.sharedInstance().schedules[key] else {
            
            //no key for that date
            return false
        }

        //events exist on this date
        return true
        
    }
    
    //retrieves schedule for date, if one exists
    func getScheduleForDate(date: NSDate?) -> SSSchedule? {
        
        //unwrap optional date
        guard let date = date else {
            
            //no date selected
            return nil
        }
        
        //get key for date
        let key = self.dateFormatter.stringFromDate(date)
        
        //check if events exist and if so for schedules on that date using the aboive key
        guard let schedule = SSSchedule.sharedInstance().schedules[key] else {
            
            //no events, or schedules on that date
            return nil
        }
        
        //return schedule
        return schedule
    }
    
    //test function
    //TODO: DELETE THIS
    func createAllMonthEvents() {
//        self.eventsByDate = NSMutableDictionary()
        let today = self.dateFormatter.dateFromString("01-12-2015")!
        
        for var i = 0; i < 80; i++ {
            
            let day = NSDate(timeInterval: Double(3600 * 24 * i), sinceDate: today)
            //create random shift
            let randomNum = arc4random()
            let rawVal = Int(randomNum % 2 + 1)
            let shift = SSShift(type: SSShiftType(rawValue: rawVal)!)
            let schedule = SSSchedule(forDate: day, withShift: shift, withNotes: [SSNote()], forUser: "Brian")
            SSSchedule.sharedInstance().schedules[self.dateFormatter.stringFromDate(day)] = schedule
            
        }
    }
    
    //test function
    //TODO: DELETE THIS
    func createSetEvents() {
        
        let key1 = "06-12-2015"
        let key2 = "13-12-2015"
        let key3 = "20-12-2015"
        let key4 = "27-12-2015"
        let key5 = "14-12-2015"
        let key6 = "03-01-2016"
        
        let note1 = SSNote(title: "Schedule 1", body: key1)
        let note2 = SSNote(title: "Schedule 2", body: key2)
        let note3 = SSNote(title: "Schedule 3", body: key3)
        let note4 = SSNote(title: "Schedule 4", body: key4)
        let note5 = SSNote(title: "Schedule 5", body: key5)
        let note6 = SSNote(title: "Schedule 6a", body: key6)
        let note7 = SSNote(title: "Schedule 6b", body: nil)
        
        guard let date1 = self.dateFormatter.dateFromString(key1),
            date2 = self.dateFormatter.dateFromString(key2),
            date3 = self.dateFormatter.dateFromString(key3),
            date4 = self.dateFormatter.dateFromString(key4),
            date5 = self.dateFormatter.dateFromString(key5),
            date6 = self.dateFormatter.dateFromString(key6)
        else {
            print("no events set")
            return
        }
        
        SSSchedule.sharedInstance().schedules = [
            key1 : SSSchedule(forDate: date1, withShift: SSShift(type: .DAY), withNotes: [note1], forUser: "Brian"),
            key2 : SSSchedule(forDate: date2, withShift: SSShift(type: .NIGHT), withNotes: [note2], forUser: "Brian"),
            key3 : SSSchedule(forDate: date3, withShift: SSShift(type: .NIGHT), withNotes: [note3], forUser: "Brian"),
            key4 : SSSchedule(forDate: date4, withShift: SSShift(type: .DAY), withNotes: [note4], forUser: "Brian"),
            key5 : SSSchedule(forDate: date5, withShift: SSShift(type: .DAY), withNotes: [note5], forUser: "Brian"),
            key6 : SSSchedule(forDate: date6, withShift: SSShift(type: .NIGHT), withNotes: [note6, note7], forUser: "Brian")
        ]
    }
    
    //test function
    //TODO: DELETE THIS
    func createRandomEvents() {
//        self.eventsByDate = NSMutableDictionary()
        
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
                let key = self.dateFormatter.stringFromDate(randomDate)
                if /*self.eventsByDate![key]*/ SSSchedule.sharedInstance().schedules[key] == nil {
                    SSSchedule.sharedInstance().schedules[key] = schedule
                }
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

