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
    @NSManaged var userName : String!
    @NSManaged var userID : String!
    @NSManaged var dateCreated : NSDate?
    @NSManaged var letsView : NSMutableArray?
    @NSManaged var canView : NSMutableArray?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(userName: String, userID : String, schedules : [SSSchedule]?, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("SSUser", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        //create empty array of schedules
        self.schedules = schedules
        self.userName = userName
        self.userID = userID
        self.dateCreated = NSDate()
        self.letsView = nil
        self.canView = nil
    }
    
    //add user to list of friends
    func allowUserToView(user: SSUser) {
        
        //add userID to letsView
        self.letsView?.addObject(user.userID)
        
        //TODO: POST to grant permissions to user
    }
    
    //disallow user from viewing schedules
    func disallowUserToView(user : SSUser) {
        
        //remove from letsView
        self.letsView?.removeObjectIdenticalTo(user.userID)
        
        //TODO: POST to remove permissions to user
    }
    
    

}
