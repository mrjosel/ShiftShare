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
class CalendarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, JTCalendarDelegate {
        
    //vars for logging events in calendar
    var eventsByDate : NSMutableDictionary?
    
    //calendar manager
    var calendarManager : JTCalendarManager!
    
    //date formatter
    let dateFormatter = NSDateFormatter()
    
    //date is selected when a user touches that dayView
    var selectedDate : NSDate?
    
    //locale for use in displaying date formats
    var locale : String?
    
    //longPress gesture recognizer
    var longPress : UILongPressGestureRecognizer?

    //outlets
    @IBOutlet weak var monthSelectorView: JTCalendarMenuView!
    @IBOutlet weak var calendarView: JTHorizontalCalendarView!
    @IBOutlet weak var dayViewTableView: UITableView!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var calendarViewHeight: NSLayoutConstraint!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var scheduleEditCancelTodayButton: SSButton!
    @IBOutlet weak var scheduleEditDoneButton: SSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
                
        //delegate and dataSource for tableView, as well as longPressGestureRecognizer
        self.longPress = UILongPressGestureRecognizer(target: self, action: "longPress:")
        self.dayViewTableView.delegate = self
        self.dayViewTableView.dataSource = self
        self.dayViewTableView.addGestureRecognizer(longPress!)
        
        //set up date formatter
        self.dateFormatter.dateFormat = "dd-MM-yyyy"
        
        //create calendar manager, set vc to calendar manager delegate
        self.calendarManager = JTCalendarManager()
        self.calendarManager.delegate = self
        
        //create random events for testability
        //TODO: DELETE THIS
//        self.createRandomEvents()
//        self.createAllMonthEvents()
        self.createSetEvents()
        
        //setup views
        self.calendarManager.menuView = self.monthSelectorView
        self.calendarManager.contentView = self.calendarView
        self.calendarManager.setDate(NSDate())
        self.locale = NSLocale.currentLocale().localeIdentifier
        self.dayLabel.text = NSDate().readableDate()
        self.scheduleEditDoneButton.ssButtonType = SSButtonType.DONE
        self.scheduleEditDoneButton.hostViewController = self
        self.scheduleEditCancelTodayButton.ssButtonType = SSButtonType.TODAY
        self.scheduleEditCancelTodayButton.hostViewController = self
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
        
        //get schedule for date
        if let events = self.eventsByDate, schedule = events[self.dateFormatter.stringFromDate(dayView.date)] as? SSScheduleForDay {
            dayView.schedule = schedule
            
            //TODO: MOVE THIS DAYVIEW CLASS?
            //TODO: PICS OVERLAP, RACE CONDITION?
            //get image if it exists
            if let image = schedule.shift.image {
                //layout the imageView
                dispatch_async(dispatch_get_main_queue(), {
                    print("setting image for \(dayView.date.readableDate())")
                    dayView.ssDVImageView = UIImageView(frame: dayView.frame)
                    dayView.ssDVImageView!.contentMode = UIViewContentMode.ScaleAspectFit
                    dayView.ssDVImageView!.image = image
                    dayView.addSubview(dayView.ssDVImageView!)
                    dayView.sendSubviewToBack(dayView.ssDVImageView!)
                })
            }
        }
        
        //format for today's date
        if calendar.dateHelper.date(NSDate(), isTheSameDayThan: dayView.date) {
            
            //set UI accordingly
            dayView.circleView.hidden = false
            dayView.circleView.backgroundColor = UIColor.blueColor()
            dayView.dotView.backgroundColor = UIColor.whiteColor()
            dayView.textLabel.textColor = UIColor.whiteColor()
        
        //selected date
        } else if self.selectedDate != nil && calendar.dateHelper.date(self.selectedDate, isTheSameDayThan: dayView.date) {

            //set UI accordingly
            dayView.circleView.hidden = false
            dayView.circleView.backgroundColor = UIColor.redColor()
            dayView.dotView.backgroundColor = UIColor.whiteColor()
            dayView.textLabel.textColor = UIColor.whiteColor()
        
        //other month
        } else if !calendar.dateHelper.date(self.calendarView.date, isTheSameMonthThan: dayView.date) {

            //set UI accordingly
            dayView.circleView.hidden = true
            dayView.dotView.backgroundColor = UIColor.redColor()
            dayView.textLabel.textColor = UIColor.lightGrayColor()
            
        //another day of the current month
        } else {

            dayView.circleView.hidden = true
            dayView.dotView.backgroundColor = UIColor.redColor()
            dayView.textLabel.textColor = UIColor.blackColor()
        }
        
        //check if there is an event set for that day
        dayView.dotView.hidden = !self.haveEventForThatDay(dayView.date)
        //TODO: METHOD IS CALLED FOR DATES MULTIPLE TIMES
    }
    
    //code for handling touching the dayView of the calendar
    func calendar(calendar: JTCalendarManager!, didTouchDayView dayView: UIView!) {
        
        //cast dayView to ShiftShareDayView
        guard let dayView = dayView as? SSDayView else {
            //failed to cast, abort
            //TODO: REMOVE IN PRODUCTION
            abort()
        }
        
        //display date in label
        self.dayLabel.text = dayView.date.readableDate()
        
        //get selected date
        self.selectedDate = dayView.date
        
        
        //TODO: REMOVE LATER
        if let schedule = dayView.schedule {
//            schedule.shift.cycleShift()
            print(schedule.shift)
        }
        
//        //animation for the circle view
//        dayView.circleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1)
//        UIView.transitionWithView(dayView, duration: 0.3, options: UIViewAnimationOptions(), animations: {
//            dayView.circleView.transform = CGAffineTransformIdentity
//            calendar.reload()
//            }, completion: nil)
        
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
        
        print(dayView)

    }
    
    //functions to carry out when Today/Cancel button is pressed based on which Type the button is
    func editCancelTodayButtonPressed(sender: SSButton) {
        
        //check which type button is
        switch sender.ssButtonType {
            //Today Button
        case .TODAY :
            //clear out selected date, dayView set calendarManager date to today, reload table
            self.selectedDate = nil
            self.calendarManager.setDate(NSDate())
            self.dayLabel.text = NSDate().readableDate()
            self.dayViewTableView.reloadData()
            
            //TODO: DEBUG, REMOVE LATER
            for (key, schedule) in self.eventsByDate! {
                print("\(key) = \((schedule as! SSScheduleForDay).shift)")
            }
            
        case .CANCEL :
            //discard changes in scheduleEdit mode
            //TODO: DISCARD ALL CHANGES
            
            //go back to month view
            self.weekMonthView()
        case .DONE :
            //commit changes
            //TODO: MAKE METHOD TO SAVE CHANGES
            
            //go back to month view
            self.weekMonthView()
        default :
            //unknown sender
            break
        }
    }
    
    func longPress(sender: UILongPressGestureRecognizer) {
        
        //only allow cell to be selected once
        if sender.state == .Began {
            
            //get point where long press occurs
            let point = sender.locationInView(self.dayViewTableView)
            
            //get indexPath at point
            guard let indexPath = self.dayViewTableView.indexPathForRowAtPoint(point) else {
                
                //no indexPath found, return
                return
            }
            
            //deselect all selected cells
            self.dayViewTableView.deselectAllCells()
            
            //present week view
            self.weekMonthView()

        }
    }
    
    //number of rows in tableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //get dayView and schedule if they exist, return 0 otherwise
        guard let schedule = self.getScheduleForDate(self.selectedDate) else {
            tableView.hidden = true
            return 0
        }
        
        //number of rows equal to shift plus number of notes
        let cellCount = (schedule.shift == .NOSHIFT) ? schedule.notes.count : schedule.notes.count + 1
        
        //show/hide tableView depending on number of cells (should never return anything less than 0)
        tableView.hidden = cellCount <= 0
        
        //return cellCount
        return cellCount

    }
    
    //creates cells for tableView
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //create cell
        guard let cell = tableView.dequeueReusableCellWithIdentifier("SSTableViewCell") as? SSTableViewCell else {
            return UITableViewCell()
        }
        
        //no selection style
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }
    
    //what to do when cell is tapped
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("cell was pressed")
    }
    
    //toggles between week and month view
    func weekMonthView() {
        
        //toggle week/month mode and reload
        self.calendarManager.settings.weekModeEnabled = !self.calendarManager.settings.weekModeEnabled
        
        //set calendarView date to selectedDate if not nil, leave the same otherwise
        if let dayForWeekView = self.selectedDate {
            self.calendarView.date = dayForWeekView
        }
        
        self.calendarManager.reload()
        
        //get height of calendarView based on whether or not your in week or month mode, set constraint to height
        let newHeight : CGFloat = self.calendarManager.settings.weekModeEnabled ? 85 : 300
        self.calendarViewHeight.constant = newHeight
        
        //show schedule edit done button only if in week mode
        self.scheduleEditDoneButton.hidden = !self.calendarManager.settings.weekModeEnabled
        
        //if in week mode, make button cancel, else make it today
        self.scheduleEditCancelTodayButton.ssButtonType = (self.calendarManager.settings.weekModeEnabled) ? SSButtonType.CANCEL : SSButtonType.TODAY
        
        //layout if needed
        self.view.layoutIfNeeded()
    }
    
    //returns bool if an event is scheduled for that day
    func haveEventForThatDay(date: NSDate) -> Bool {
        
        //setup key for date
        let key = self.dateFormatter.stringFromDate(date)
        
        //check if there is an event for the key
        guard let events = self.eventsByDate, _ = events[key] as? SSScheduleForDay else {
            
            //no key for that date
            return false
        }
        print("event exists on \(date.readableDate())")
        //events exist on this date
        return true
        
    }
    
    //retrieves schedule for date, if one exists
    func getScheduleForDate(date: NSDate?) -> SSScheduleForDay? {
        
        //unwrap optional date
        guard let date = date else {
            
            //no date selected
            return nil
        }
        
        //get key for date
        let key = self.dateFormatter.stringFromDate(date)
        
        //check if events exist and if so for schedules on that date using the aboive key
        guard let events = self.eventsByDate, schedule = events[key] as? SSScheduleForDay else {
            
            //no events, or schedules on that date
            return nil
        }
        
        //return schedule
        return schedule
    }
    
    //test function
    //TODO: DELETE THIS
    func createAllMonthEvents() {
        self.eventsByDate = NSMutableDictionary()
        let today = self.dateFormatter.dateFromString("01-12-2015")!
        
        for var i = 0; i < 80; i++ {
            
            let day = NSDate(timeInterval: Double(3600 * 24 * i), sinceDate: today)
            //create random shift
            let randomNum = arc4random()
            let rawVal = randomNum % 2 + 1
            guard let shift = SSShift(rawValue: Int(rawVal)) else {
                abort()
            }
            let schedule = SSScheduleForDay(forDate: day, withShift: shift, withNotes: [SSNote()], forUser: "Brian")
            self.eventsByDate![self.dateFormatter.stringFromDate(day)] = schedule
            
        }
    }
    
    //test function
    //TODO: DELETE THIS
    func createSetEvents() {
        
        let key1 = "06-12-2015"
        let key2 = "13-12-2015"
        let key3 = "20-12-2015"
        let key4 = "27-12-2015"
        let key5 = "14-12-2015" //WHAT THE FUCK
        let key6 = "03-01-2016"
        
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
        
        self.eventsByDate = [
            key1 : SSScheduleForDay(forDate: date1, withShift: SSShift.DAY, withNotes: [SSNote()], forUser: "Brian"),
            key2 : SSScheduleForDay(forDate: date2, withShift: SSShift.NIGHT, withNotes: [SSNote()], forUser: "Brian"),
            key3 : SSScheduleForDay(forDate: date3, withShift: SSShift.NIGHT, withNotes: [SSNote()], forUser: "Brian"),
            key4 : SSScheduleForDay(forDate: date4, withShift: SSShift.DAY, withNotes: [SSNote()], forUser: "Brian"),
            key5 : SSScheduleForDay(forDate: date5, withShift: SSShift.DAY, withNotes: [SSNote()], forUser: "Brian"),
            key6 : SSScheduleForDay(forDate: date6, withShift: SSShift.NIGHT, withNotes: [SSNote()], forUser: "Brian")
        ]
        
    }
    
    //test function
    //TODO: DELETE THIS
    func createRandomEvents() {
        self.eventsByDate = NSMutableDictionary()
        
        for var i = 0; i < 10; i++ {
            
            //create random date from today
            let today = NSDate()
            let mod = Int32(3600 * 24 * 60)
            let randomNum = arc4random()
            let intervalNum = randomNum % UInt32(mod)
            let intervalNumDouble = Double(intervalNum)
            let interval = NSTimeInterval.abs(intervalNumDouble)
            let randomDate = NSDate(timeInterval: interval, sinceDate: today)
            
            //create random shift
            let rawVal = randomNum % 7
            guard let shift = SSShift(rawValue: Int(rawVal)) else {
                abort()
            }
            
            //create notes for the day
            let count = Int(randomNum % 3)
            var notes : [SSNote] = []
            for var j = 0; j < count; j++ {
                let note = SSNote(title: "Note\(count)", body: nil)
                notes.append(note)
            }
            
            //make schedule from shift and notes
            let schedule = SSScheduleForDay(forDate: randomDate, withShift: shift, withNotes: notes, forUser: "Brian")
            let key = self.dateFormatter.stringFromDate(randomDate)
            
            if self.eventsByDate![key] == nil {
                self.eventsByDate![key] = schedule
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

