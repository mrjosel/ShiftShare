//
//  ExtensionsAndProtocols.swift
//  Shift Share
//
//  Created by Brian Josel on 11/20/15.
//  Copyright © 2015 Brian Josel. All rights reserved.
//
//  Extensions of existing CocoaTouch and custom classes as well as custom protocols


import Foundation
import UIKit
import JTCalendar
import CoreData

//extending UITableView to allow for deselecting all cells
extension UITableView {
    
    //runs through all cells in visible cells and sets selected parameter to false
    func deselectAllCells() {
        for cell in self.visibleCells {
            cell.selected = false
        }
    }
}

//custom color for Today's Date
extension UIColor {
    public class func todayColor() -> UIColor {
        return UIColor(red: 97/255.0, green: 194/255.0, blue: 250/255.0, alpha: 1.0)
    }
}

//allows easily getting date information in readable text, or for use in keying dicts
extension NSDate {
    
    var keyFromDate: String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return dateFormatter.stringFromDate(self)
    }
    
    var month: String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.stringFromDate(self)
    }
    
    var day: String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd"
        //helps display days at 7, 8, 9 instead of 07, 08, 09
        if let intDay = Int(dateFormatter.stringFromDate(self)) {
            return String(intDay)
        }
        return dateFormatter.stringFromDate(self)
        
    }
    
    var year: String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.stringFromDate(self)
    }
    
    //outputs readable date
    //TODO: MAKE PRINTOUT DIFFERENT BY COUNTRY?
    var readableDate : String  {
        get {
            return self.month + ", " + self.day + " " + self.year
        }
    }
}

//extending to allow for double tap gestures
extension JTCalendarDelegateManager {
    
    //double tapped dayView
    func didDoubleTapDayView(dayView: UIView!) {
        
        //get manager and delegate, can't continue otherwise
        guard let manager = self.manager, delegate = manager.delegate as? SSCalendarDelegate else {
            return
        }
        
        //execute double tap in delegate
        if delegate.respondsToSelector("calendar:didDoubleTapDayView:") {
            delegate.calendar(manager, didDoubleTapDayView: dayView)
        }
    }
}

//allows for easy population of tableCell data
protocol SSScheduleItem : AnyObject {
    
    //image for shift
    var imageName : String? {get}
    
    //string for title (shift, note title, etc)
    var title : String? {get set}
    
    //string for body/description of note
    var body : String? {get set}
    
    //schedule for data
    var schedule : SSSchedule? {get set}
    
}