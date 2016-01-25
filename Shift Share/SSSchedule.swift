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
    var shift : SSShift? //{
//        didSet {
//            //alert the delegate
//            self.manager?.didChangeShiftOrType(self)
//        }
//    }
    
    //notes for the day
    var notes : [SSNote]? {
        didSet {
            //alert the delegate
            self.manager?.didChangeNoteOrContents(self)
        }
    }
    
    //schedule manager
    var manager : SSScheduleManager?
    
    //array for populating tableView
    var tableData : [SSTBCellData] {
        get {
            
            var output = [SSTBCellData]()
            
            if let notes = self.notes {
                for note in notes.reverse() {
                    output.insert(note, atIndex: 0)
                }
            }
            
            if let shift = self.shift {
                output.insert(shift, atIndex: 0)
            }
            //TODO: IMPLELEMENT DOUBLETAP CELL IF SWIPE FAILS
//            //append with expland/collapse cell (expand by default)
//            output.append(SSScheduleDoubleTapCell())
            
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
        
        //if shift is not nil, set shift's schedule to self
        if let shift = self.shift {
            shift.schedule = self
        }
        self.notes = notes
        
        //do the same thing for every note in notes
        if let notes = self.notes {
            for note in notes {
                note.schedule = self
            }
        }
        
        self.user = user as? String //TODO: FIX WHEN USER OBJECT IS IMPLEMENTED

    }
    
//    //cell that instructs user to double tap expand/collapse table/month views. Cell is of typse SSNote arbitrarily
//    class func doubleTapCell(expandOrCollapse: SSScheduleDoubleTapCellType) -> SSTBCellData {
//        
//        //output cell
//        let outputCell = SSNote()
//        outputCell.image = nil   //force image nil
//        
//        //check string value for expandOrCollapse
//        switch expandOrCollapse {
//        case .EXPAND :
//            outputCell.title = "Double Tap Day to Expand"
//        case .COLLAPSE :
//            outputCell.title = "Double Tap Day to Collapse"
//        }
//        
//        return outputCell
//    }
//
    
    //class func to return "schedule" to populate table when there is no schedule for that date
    class func emptyTableData() -> [SSTBCellData] {
        
        //create dummy data from SSShift class
        let emptyData = SSShift()
        emptyData.title = "No Schedule"
        return [emptyData]
    }
    
    class func  sharedInstance() -> SSSchedule {
        struct Singleton {
            static let instance = SSSchedule()
        }
        return Singleton.instance
    }
}