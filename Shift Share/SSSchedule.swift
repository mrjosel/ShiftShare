//
//  SSSchedule.swift
//  Shift Share
//
//  Created by Brian Josel on 11/25/15.
//  Copyright © 2015 Brian Josel. All rights reserved.
//

import Foundation
import CoreData

@objc(SSSchedule)

//persisted object for a schedule for that day
class SSSchedule : NSManagedObject {
    //set and get commands for use in coreData to allow using property observers, which @NSManged var prohibits
    
    //schedules across application, used by singleton
//    var schedules = [String : SSSchedule]()

    //date for the object
    @NSManaged var date : NSDate?
    
    //user associated with schedule
    @NSManaged var user : String?
    
    //shift for the day
    @NSManaged var shift : SSShift?

    //notes for the day
    @NSManaged var notes : [SSNote]?
    
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
            
            return output
        }
    }
    
    //initializers
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    //init with params
    init(forDate date: NSDate?, forUser user: AnyObject?, context: NSManagedObjectContext) {
        
        //coredata
        let entity = NSEntityDescription.entityForName("SSSchedule", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        //set params to properties
        self.date = date
        self.user = user as? String //TODO: FIX WHEN USER OBJECT IS IMPLEMENTED

    }
    
    //class func to return "schedule" to populate table when there is no schedule for that date
    class func emptyTableData() -> [SSTBCellData] {
        
        //create dummy data from SSShift class
        let emptyData = SSNote(title: "No Schedule", body: nil, context: CoreDataStackManager.sharedInstance().scratchContext)
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
}