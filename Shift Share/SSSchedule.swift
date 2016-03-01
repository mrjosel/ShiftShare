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
    @NSManaged var user : SSUser?
    
    //shift for the day
    @NSManaged var shift : SSShift?

    //notes for the day
    @NSManaged var notes : [SSNote]?
    
    //array for populating tableView
    var tableData : [SSScheduleItem] {
        get {
            
            var output = [SSScheduleItem]()
            
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
    init(forDate date: NSDate?, forUser user: SSUser?, context: NSManagedObjectContext) {
        
        //coredata
        let entity = NSEntityDescription.entityForName("SSSchedule", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        //set params to properties
        self.date = date
        self.user = user

    }
}