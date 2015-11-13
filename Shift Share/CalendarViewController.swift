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
class CalendarViewController: UIViewController, JTCalendarDelegate {
    
    //vars for logging events in calendar
    var eventsByDate : NSMutableDictionary!
    var todayDate = NSDate()    //making variable only for readibility's sake
    var minDate : NSDate!
    var maxDate : NSDate!
    //TODO: REMOVE selectedDate AND REFACTOR WITH dayView.date
    var selectedDate : NSDate!

    //outlets
    @IBOutlet weak var monthSelectorView: JTCalendarMenuView!
    @IBOutlet weak var calendarView: JTHorizontalCalendarView!
    
    //calendar manager
    var calendarManager : JTCalendarManager!
    
    //date formatter
    let dateFormatter = NSDateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //set up date formatter
        self.dateFormatter.dateFormat = "dd-MM-yyyy"
        
        //create calendar manager, set vc to calendar manager delegate
        self.calendarManager = JTCalendarManager()
        self.calendarManager.delegate = self
        
        //create random events for testability
        //TODO: DELETE THIS
        self.createRandomEvents()
        
        //get min and max dates
        self.createMinAndMaxDates()
        
        //setup views
        self.calendarManager.menuView = self.monthSelectorView
        self.calendarManager.contentView = self.calendarView
        self.calendarManager.setDate(self.todayDate)

    }
    
    //delegate method to prepare day view
    func calendar(calendar: JTCalendarManager!, prepareDayView dayView: UIView!) {
        
        //cast dayView to JTCalendarDayView
        guard let dayView = dayView as? JTCalendarDayView else {
            //failed to cast, abort
            //TODO: REMOVE IN PRODUCTION
            abort()
        }
        
        //format for today's date
        if calendar.dateHelper.date(NSDate(), isTheSameDayThan: dayView.date) {
            
            //set UI accordingly
            dayView.circleView.hidden = false
            dayView.circleView.backgroundColor = UIColor.blueColor()
            dayView.dotView.backgroundColor = UIColor.whiteColor()
            dayView.textLabel.textColor = UIColor.whiteColor()
        
        //selected date
        } else if calendar.dateHelper.date(self.selectedDate, isTheSameDayThan: dayView.date) {
            
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
            
            //set UI accordingly
            dayView.circleView.hidden = true
            dayView.dotView.backgroundColor = UIColor.redColor()
            dayView.textLabel.textColor = UIColor.blackColor()
        }
        
        //check if there is an event set for that day
        dayView.dotView.hidden = self.haveEventForThatDay(dayView.date)
    }
    
    //code for handling touching the dayView of the calendar
    func calendar(calendar: JTCalendarManager!, didTouchDayView dayView: UIView!) {
        
        //cast dayView as JTCalendarDayView
        guard let dayView = dayView as? JTCalendarDayView else {
            //failed to cast, abort
            //TODO: REMOVE IN PRODUCTION
            abort()
        }
        
        //get selected date
        self.selectedDate = dayView.date
        
        //animation for the circle view
        dayView.circleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1)
        UIView.transitionWithView(dayView, duration: 0.3, options: UIViewAnimationOptions(), animations: {
            dayView.circleView.transform = CGAffineTransformIdentity
            calendar.reload()
            }, completion: nil)
        
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
        
    }
    
    //returns bool if an event is scheduled for that day
    func haveEventForThatDay(date: NSDate) -> Bool {
        
        //setup key for date
        let key = self.dateFormatter.stringFromDate(date)
        
        //check if there is an event for the key
        guard let events = self.eventsByDate[key] else {
            
            //no key for that date
            return false
        }
        
        //key exists, check if events for key has a count greater than 0
        if !(events.count > 0) {
            
            //no events on that date
            return false
        }
        
        //events exist on this date
        return true
        
    }
    
    //get min and max dates for the calendar view based on today's date
    func createMinAndMaxDates() {
        
        //minDate is 2 months prior to today
        self.minDate = self.calendarManager.dateHelper.addToDate(self.todayDate, months: -2)
        
        //maxDate is 2 months after today
        self.maxDate = self.calendarManager.dateHelper.addToDate(self.todayDate, months: 2)
    }
    
    //test function
    //TODO: DELETE THIS
    func createRandomEvents() {
        self.eventsByDate = NSMutableDictionary()
        
        for var i = 0; i < 30; i++ {
            
            let today = self.todayDate
            let mod = Int32(3600 * 24 * 60)
            let randomNum = rand()
            let intervalNum = randomNum % mod
            let intervalNumDouble = Double(intervalNum)
            let interval = NSTimeInterval.abs(intervalNumDouble)
            let randomDate = NSDate(timeInterval: interval, sinceDate: today)
            
            let key = self.dateFormatter.stringFromDate(randomDate)
            
            if self.eventsByDate[key] == nil {
                self.eventsByDate[key] = NSMutableArray()
            }
            self.eventsByDate[key]?.addObject(randomDate)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

