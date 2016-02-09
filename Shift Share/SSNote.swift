//
//  SSNote.swift
//  Shift Share
//
//  Created by Brian Josel on 11/19/15.
//  Copyright © 2015 Brian Josel. All rights reserved.
//

import Foundation
import UIKit
import CoreData

//notes to populate SSDayViews
class SSNote : NSManagedObject, SSTBCellData {
    
    //title, body, image for protocol conformance
    //set and get commands for use in coreData to allow using property observers, which @NSManged var prohibits
    var title : String? {
        set {
            
            self.willChangeValueForKey("title")
            self.setPrimitiveValue(newValue, forKey: "title")
            self.didChangeValueForKey("title")
            
            //alert the delegate
            self.schedule?.manager?.didChangeNoteOrContents(self.schedule!)
        }

        get {
            self.willAccessValueForKey("title")
            let text = self.primitiveValueForKey("title") as? String
            self.didAccessValueForKey("title")
            return text
        }
    }
    var body : String? {
        set {

            self.willChangeValueForKey("body")
            self.setPrimitiveValue(newValue, forKey: "body")
            self.didChangeValueForKey("body")

            //alert the delegate
            self.schedule?.manager?.didChangeNoteOrContents(self.schedule!)
        }
        
        get {
            self.willAccessValueForKey("body")
            let text = self.primitiveValueForKey("body") as? String
            self.didAccessValueForKey("body")
            return text
        }
    }
    var image : UIImage? = UIImage(named: "Note")  //Note image is always of "Note"
    
    //schedule assiciated with note
    var schedule : SSSchedule? {
        set {
            
            self.willChangeValueForKey("schedule")
            self.setPrimitiveValue(newValue, forKey: "schedule")
            self.didChangeValueForKey("schedule")

        }
        
        get {
            self.willAccessValueForKey("schedule")
            let _schedule = self.primitiveValueForKey("schedule") as? SSSchedule
            self.didAccessValueForKey("schedule")
            return _schedule
        }
    }
    
    //description for CustomStringConvertible conformance
    override var description : String {
        get {
            //if no title, return String of self
            guard let title = self.title else {
                return "\(self)"
            }
            
            //title exists, check for body
            guard let body = self.body else {
                return title
            }
            
            //title and body both exist
            return "\(title) (body: \(body))"
        }
    }
    
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
        
    }
}