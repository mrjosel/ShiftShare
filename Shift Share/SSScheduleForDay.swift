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
class SSScheduleForDay {
    
    //date for the object
    var date : NSDate?
    
    //user associated with schedule
    var user : AnyObject?   //TODO: MAKE USER NSMANAGEDOBJECT
    
    //shift for the day
    var shift : SSShift?
    
    //notes for the day
    var notes : [SSNote]?
    
    //array for populating tableView
    var tableData : [SSTBCellData] {
        get {
            
            var output = [SSTBCellData]()
            
            if let notes = self.notes {
                output = notes
            }
            
            if let shift = shift {
                output.insert(shift, atIndex: 0)
            }
            return output
        }
    }
    
    //initializers
    init() {/*empty*/}
    
    //init with params
    init(forDate date: NSDate?, withShift shift: SSShift?, withNotes notes: [SSNote]?, forUser user: AnyObject?) {
        
        //set params to properties
        self.date = date
        self.shift = shift
        self.notes = notes
        self.user = user as? String //TODO: FIX WHEN USER OBJECT IS IMPLEMENTED
        
        //create table data if values are not optional, leave [] otherwise

    }
    
    //class func to return "schedule" to populate table when there is no schedule for that date
    class func emptyTableData() -> [SSTBCellData] {
        
        return [SSShift()]
    }
    
    //class func to return text for table when in edit mode
    class func editModeTableData() -> [SSTBCellData] {
        
        return [SSShift.editMode(), SSNote.editMode()]
    }
}