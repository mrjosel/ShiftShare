//
//  SSShift.swift
//  Shift Share
//
//  Created by Brian Josel on 11/19/15.
//  Copyright © 2015 Brian Josel. All rights reserved.
//

import Foundation
import UIKit
import CoreData

//class for actual shift
class SSShift : NSManagedObject, SSTBCellData {
    
    //shift type
    var type : SSShiftType? {
        didSet {
//            //TODO: REFACTOR TO GET SHIFTTYPE ENUM NO LONGER ENUM????
//            // checkout - http://stackoverflow.com/questions/26900302/swift-storing-states-in-coredata-with-enums
//            self.willChangeValueForKey("type")
//            self.setPrimitiveValue(newValue, forKey: "type")
//            self.didChangeValueForKey("type")
            
            //set persisted type
            self.persistedType = self.type?.rawValue
            
            //alert the delegate
            self.schedule?.manager?.didChangeShiftOrType(self.schedule!)
        }
        
//        get {
//            self.willAccessValueForKey("type")
//            let _type = self.primitiveValueForKey("type") as? SSShiftType
//            self.didAccessValueForKey("type")
//            return _type
//        }
    }
    
    //persisted type, since enums not easily persisted in Swift 2.0
    @NSManaged var persistedType : NSNumber?
    
    //protocol values set when type is set
    @NSManaged var imageName : String?
    @NSManaged var title : String?
    @NSManaged var body: String?
    
    //schedule associated with shift
    var schedule : SSSchedule?
    
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
            self.title = SSShiftType.shiftNames[type]
            self.body = SSShiftType.shiftTimes[type]
            self.imageName = /*UIImage(named: */SSShiftType.shiftNames[type]//!)
            self.persistedType = type.rawValue
        } else {
            //no type specified
            self.type = nil
            self.title = "No Shift"
            self.body = nil
            self.imageName = nil
            self.persistedType = nil
        }
    }
    
//    //empty initializer
//    init() {
//        
//        //no type specified
//        self.type = nil
//        self.title = "No Shift"
//        self.body = nil
//        self.image = nil
//    }
}