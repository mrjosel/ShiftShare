//
//  SSSchedule.swift
//  Shift Share
//
//  Created by Brian Josel on 11/25/15.
//  Copyright © 2015 Brian Josel. All rights reserved.
//

import Foundation
import UIKit
import JTCalendar
import CoreData

//type to switch for doubleTapCell
enum SSScheduleDoubleTapCellType {
    case EXPAND, COLLAPSE
}

//persisted object for a schedule for that day
//TODO: MAKE OBJECT NSMANAGEDOBJECT
class SSSchedule {
    
    //schedules across application, used by singleton
    var schedules = [String : SSSchedule]()
    
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
    
    //cell that instructs user to double tap expand/collapse table/month views. Cell is of typse SSNote arbitrarily
    class func doubleTapCell(expandOrCollapse: SSScheduleDoubleTapCellType) -> SSTBCellData {
        
        //output cell
        let outputCell = SSNote()
        outputCell.image = nil   //force image nil
        
        //check string value for expandOrCollapse
        switch expandOrCollapse {
        case .EXPAND :
            outputCell.title = "Double Tap Day to Expand"
        case .COLLAPSE :
            outputCell.title = "Double Tap Day to Collapse"
        }
        
        return outputCell
    }
    
    //class func to return "schedule" to populate table when there is no schedule for that date
    class func emptyTableData() -> [SSTBCellData] {
        
        return [SSShift()]
    }
    
    class func  sharedInstance() -> SSSchedule {
        struct Singleton {
            static let instance = SSSchedule()
        }
        return Singleton.instance
    }
}