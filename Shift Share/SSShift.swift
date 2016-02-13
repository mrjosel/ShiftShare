//
//  SSShift.swift
//  Shift Share
//
//  Created by Brian Josel on 11/19/15.
//  Copyright © 2015 Brian Josel. All rights reserved.
//

import Foundation
import CoreData

@objc(SSShift)

//class for actual shift
class SSShift : NSManagedObject, SSScheduleItem {
    
    //shift type
    var type : SSShiftType? {
        didSet {
            
            //set persisted type
            self.persistedType = self.type?.rawValue
            
        }
    }
    
    //persisted type, since enums not easily persisted in Swift 2.0
    @NSManaged var persistedType : NSNumber?
    
    //protocol values set when type is set
    @NSManaged var title : String?
    @NSManaged var body: String?
    @NSManaged var imageName : String?
    
    //schedule associated with shift
    @NSManaged var schedule : SSSchedule?
    
    //initializers
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(type: SSShiftType?, context: NSManagedObjectContext) {
        
        //coreData
        let entity = NSEntityDescription.entityForName("SSShift", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        
        if let type = type {
            //type was set properly
            self.type = type
            self.imageName = SSShiftType.shiftNames[type]
            self.title = SSShiftType.shiftNames[type]
            self.body = SSShiftType.shiftTimes[type]
            self.persistedType = type.rawValue
            
        }
    }
}