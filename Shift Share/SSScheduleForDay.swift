//
//  SSScheduleForDay.swift
//  Shift Share
//
//  Created by Brian Josel on 11/25/15.
//  Copyright © 2015 Brian Josel. All rights reserved.
//

import Foundation
import UIKit
import JTCalendar
import CoreData

//persisted object for a schedule for that day
//TODO: MAKE OBJECT NSMANAGEDOBJECT
class SSScheduleForDay : CustomStringConvertible {
    
    //date for the object
    var date : NSDate
    
    //user associated with schedule
    var user : String   //TODO: MAKE USER NSMANAGEDOBJECT
    
    //shift for the day
    var shift : SSShift
    
    //notes for the day
    var notes : [SSNote]
    
    //description for CustomStringConvertible conformance
    var description : String {
        get {
            if self.user == "NO USER" /*TODO: FIX WHEN USER OBJECT IS IMPLEMENTED*/ {
                return "\(self)"
            }
            return "\(user)'s schedule for \(date.readableDate())"
        }
    }
    
    //initializers
    init() {
        
        //may as well be today's date
        self.date = NSDate()
        
        //no shift, no notes, no user
        self.shift = SSShift.NOSHIFT
        self.notes = []
        self.user = "NO USER"  //TODO: FIX WHEN USER OBJECT IS IMPLEMENTED
        
    }
    
    //init with params
    init(forDate date: NSDate, withShift shift: SSShift, withNotes notes: [SSNote], forUser user: AnyObject) {
        
        //set params to properties
        self.date = date
        self.shift = shift
        self.notes = notes
        self.user = user as! String //TODO: FIX WHEN USER OBJECT IS IMPLEMENTED
        
    }
}