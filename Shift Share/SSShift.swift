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
            if let type = self.type {
                //set persisted type
                self.imageName = SSShiftType.shiftNames[type]
                self.title = SSShiftType.shiftNames[type]
                self.body = SSShiftType.shiftTimes[type]
                self.persistedType = type.rawValue
            }
            
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
    
        //set type
        self.type = type
    }
}