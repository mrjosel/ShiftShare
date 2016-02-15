//
//  SSNote.swift
//  Shift Share
//
//  Created by Brian Josel on 11/19/15.
//  Copyright © 2015 Brian Josel. All rights reserved.
//

import Foundation
import CoreData

@objc(SSNote)

//notes to populate SSDayViews
class SSNote : NSManagedObject, SSScheduleItem {
    
    //title, body, image for protocol conformance
    //set and get commands for use in coreData to allow using property observers, which @NSManged var prohibits
    @NSManaged var title : String?
    @NSManaged var body : String?
    @NSManaged var dateCreated : NSDate
    
    //schedule assiciated with note
    @NSManaged var schedule : SSSchedule?
    
    //imageName var
    @NSManaged var imageName : String?
    
    //initializers
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    //init with title, optional body
    init(title: String?, body: String?, context : NSManagedObjectContext) {
        
        //coreData
        let entity = NSEntityDescription.entityForName("SSNote", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        //set properties to params
        self.title = title
        self.body = body
        self.imageName = "Note"
        self.dateCreated = NSDate() //set date created to current time
        
    }
}