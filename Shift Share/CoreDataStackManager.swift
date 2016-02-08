//
//  CoreDataStackManager.swift
//  Shift Share
//
//  Created by Brian Josel on 2/8/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import Foundation
import CoreData

//sqlite file
private let SQLITE_FILE_NAME = "ShiftShare.sqlite"

//manager for all coreData activities
class CoreDataStackManager {
    
    //singleton
    class func sharedInstance() -> CoreDataStackManager {
        
        struct Singleton {
            static let instance = CoreDataStackManager()
        }
        
        return Singleton.instance
    }
}