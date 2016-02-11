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
class SSSchedule : NSManagedObject {
    //set and get commands for use in coreData to allow using property observers, which @NSManged var prohibits
    
    //schedules across application, used by singleton
//    var schedules = [String : SSSchedule]()
    override func awakeFromFetch() {

    }
    //date for the object
    @NSManaged var date : NSDate? //{
//        set {
//            
//            self.willChangeValueForKey("date")
//            self.setPrimitiveValue(newValue, forKey: "date")
//            self.didChangeValueForKey("date")
//            
//        }
//        
//        get {
//            self.willAccessValueForKey("date")
//            let _date = self.primitiveValueForKey("date") as? NSDate
//            self.didAccessValueForKey("date")
//            return _date
//        }
//    }
    
    //user associated with schedule
    @NSManaged var user : String? //{
//        set {
//            
//            self.willChangeValueForKey("user")
//            self.setPrimitiveValue(newValue, forKey: "user")
//            self.didChangeValueForKey("user")
//            
//        }
//        
//        get {
//            self.willAccessValueForKey("user")
//            let _user = self.primitiveValueForKey("user") as? String
//            self.didAccessValueForKey("user")
//            return _user
//        }
//    }
    
    //shift for the day
    /*@NSManaged*/ var shift : SSShift? {
        set {
            
            self.willChangeValueForKey("shift")
            self.setPrimitiveValue(newValue, forKey: "shift")
            self.didChangeValueForKey("shift")
            
            //set schedule param of shift
            if let shift = self.shift {
                shift.schedule = self
            }
            
            //alert the delegate
            self.manager?.didChangeShiftOrType(self)
        }
        
        get {
            self.willAccessValueForKey("shift")
            let _shift = self.primitiveValueForKey("shift") as? SSShift
            self.didAccessValueForKey("shift")
            return _shift
        }
    }

    //notes for the day
    var notes : [SSNote]? {
        
        set {
            
            self.willChangeValueForKey("notes")
            self.setPrimitiveValue(newValue, forKey: "notes")
            self.didChangeValueForKey("notes")
    
            //check if notes were added/created
            if let oldNotes = self.notes, newNotes = newValue {
                
                //if oldNotes is less than newNotes, then notes were added, set schedule to added note
                if oldNotes.count < newNotes.count {
                    newNotes.last?.schedule = self
                }
            } else {
                //new array set, set schedule for all notes
                if let notes = self.notes {
                    for note in notes {
                        note.schedule = self
                    }
                }
            }
            //alert the delegate
            self.manager?.didChangeNoteOrContents(self)
        }
        get {
            self.willAccessValueForKey("notes")
            let _notes = self.primitiveValueForKey("notes") as? [SSNote]
            self.didAccessValueForKey("notes")
            return _notes
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
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    //init with params
    init(forDate date: NSDate?, /*withShift shift: SSShift?, withNotes notes: [SSNote]?,*/ forUser user: AnyObject?, context: NSManagedObjectContext) {
        
        //coredata
        let entity = NSEntityDescription.entityForName("SSSchedule", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        //set params to properties
        self.date = date
//        self.shift = shift
//        
//        //if shift is not nil, set shift's schedule to self
//        //this has to be called for didSet and for the initializer
//        if let shift = self.shift {
//            shift.schedule = self
//        }
//        
//        self.notes = notes
//        
//        //do the same thing for every note in notes
//        if let notes = self.notes {
//            for note in notes {
//                note.schedule = self
//            }
//        }
        
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
        let emptyData = SSNote(title: "No Schedule", body: nil, context: CoreDataStackManager.sharedInstance().scratchContext)
//        emptyData.title = "No Schedule"
        return [emptyData]
    }
    
    //returns dummy data for use in creating new schedules
    //two cells are returned, "new shift" and "new note"
    //if a shift is made, "new shift" is replaced with the shift
    //if a note is made, its added, with "new note" remaining at the end of the stack
    class func newScheduleData(schedule: SSSchedule?) {//-> [SSTBCellData] {
        
        //make dummy data
        let newShift = SSShift(type: nil, context: CoreDataStackManager.sharedInstance().scratchContext)
        newShift.title = "New Shift"
        let newNote = SSNote(title: "New Note", body: "New Body", context: CoreDataStackManager.sharedInstance().scratchContext)
        
        //get schedule
        if let schedule = schedule {
        
            //schedule exists, check for shift and notes
            if schedule.shift == nil {

                //schedule exists, but no shift, remove shift link for purposes of creating new shifts
                schedule.shift = newShift
                schedule.shift?.schedule = nil

            }
            
            //if notes are nil, fill with [newNote[, if notes exist not equal 1, append with newNote, if count is 1, note is already newNote and do nothing
            if schedule.notes != nil {
                
                //if last element in notes is not newNote (schedule == nil), append with newNote
                if let _ = schedule.notes!.last?.schedule {
                    
                    //last element has a schedule, therefore not newNote, append newNote
                    schedule.notes!.append(newNote)
                    schedule.notes!.last?.schedule = nil
                }
            } else {
                //no notes, create notes array with newNote
                schedule.notes = [newNote]
                schedule.notes?.last?.schedule = nil
            }
            
        } else {
            
            //schedule does not exist
            let newSchedule = SSSchedule()
            newSchedule.shift = newShift
            newSchedule.notes = [newNote]
            
            //return newSchedule.tableData
        }
    }
    
//    //make temporary schedule so as not to blow away schedules when canceling edit
//    //TODO:  REMOVE LATER AND USE COREDATA
//    class func makeScratchSchedule(schedule: SSSchedule) -> SSSchedule {
//        
//        //scratch shift and notes
//        var scratchShift : SSShift?
//        var scratchNotes : [SSNote] = []
//        
//        //make scratch shift
//        if let type = schedule.shift?.type {
//            scratchShift = SSShift(type: type, context: CoreDataStackManager.sharedInstance().scratchContext)
//        }
//        
//        //make scratch notes
//        if let notes = schedule.notes {
//            for note in notes {
//                let newNote = SSNote(title: note.title, body: note.body, context: CoreDataStackManager.sharedInstance().scratchContext)
//                scratchNotes.append(newNote)
//            }
//        }
//        
//        //if scratch notes is empty, use nil for making new shift
//        if !scratchNotes.isEmpty {
//            return SSSchedule(forDate: schedule.date, withShift: scratchShift, withNotes: scratchNotes, forUser: schedule.user, context: CoreDataStackManager.sharedInstance().scratchContext)
//        } else {
//            return SSSchedule(forDate: schedule.date, withShift: scratchShift, withNotes: nil, forUser: schedule.user, context: CoreDataStackManager.sharedInstance().scratchContext)
//        }
//    }
    
//    class func  sharedInstance() -> SSSchedule {
//        struct Singleton {
//            static let entity = NSEntityDescription.entityForName("SSSchedule", inManagedObjectContext: CoreDataStackManager.sharedInstance().managedObjectContext)!
//            static let instance = SSSchedule(entity: entity, insertIntoManagedObjectContext: CoreDataStackManager.sharedInstance().managedObjectContext)
//        }
//        return Singleton.instance
//    }
}