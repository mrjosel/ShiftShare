//
//  SSUser.swift
//  Shift Share
//
//  Created by Brian Josel on 3/1/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import UIKit
import CoreData

@objc(SSUser)

//parent class to schedules
class SSUser: NSManagedObject {
    
    //managed vars
    @NSManaged var schedules : [SSSchedule]?
    @NSManaged var userName : String?
    @NSManaged var dateCreated : NSDate?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(userName: String?, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("SSUser", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        //create empty array of schedules
        self.schedules = []
        self.userName = userName
        self.dateCreated = NSDate()
    }

}
