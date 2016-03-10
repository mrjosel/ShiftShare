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
    
    //applications documents directory
    lazy var applicationsDocumentsDirectory : NSURL  = {
       
        //get urls at path
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        
        //return last url in array
        return urls.last! as NSURL
    }()
    
    //managed object model
    lazy var managedObjectModel : NSManagedObjectModel = {
       
        //get the url for the model file
        let modelURL = NSBundle.mainBundle().URLForResource("ShiftShareModel", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    //persistent store coordinatoer
    lazy var persistentStoreCoordinator : NSPersistentStoreCoordinator? = {
       
        //coordinator to be returned
        var coorindator : NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        //url to sqlite file (append documents directory with sqlite file)
        let url = self.applicationsDocumentsDirectory.URLByAppendingPathComponent(SQLITE_FILE_NAME)
        
        //error if persistent store coordinator fails to be created
        var failureReason = "The was an error creating or loading the application's saved data"
        
        do {
            try coorindator?.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            //report error if thrown
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize object's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "persistentStoreCoordinator", code: 9999, userInfo: dict)
            NSLog("Unresolved error, \(wrappedError)", "\(wrappedError.userInfo)")
            
        }
        //return coordinator if error not thrown
        return coorindator
    }()
    
    
    //managed object context - USE THIS CONTEXT WHEN CREATING OBJECTS THAT ARE INTENDED TO BE SAVED
    lazy var managedObjectContext : NSManagedObjectContext = {
       
        //coordinator
        let coordinator = self.persistentStoreCoordinator
        
        //contect to be returned
        var context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        return context
        
    }()
    
    //scratch context - USE THIS CONTEXT FOR OBJECTS THAT ARE "SCRATCH" OBJECTS
    lazy var scratchContext : NSManagedObjectContext = {
        
        //coordinator
        let coordinator = self.persistentStoreCoordinator
        
        //contect to be returned
        var context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        return context
    }()
    
    //method call to save context
    func saveContext() {
        if self.managedObjectContext.hasChanges {
            do {
                try self.managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error, \(nserror)", "\(nserror.userInfo)")
            }
        }
    }
    
    //singleton
    class func sharedInstance() -> CoreDataStackManager {
        
        struct Singleton {
            static let instance = CoreDataStackManager()
        }
        
        return Singleton.instance
    }
    
    
    //FRCs
    //fetched results controller
    lazy var scheduleFetchResultsController : NSFetchedResultsController = {
        
        //create fetch request
        let fetchRequest = NSFetchRequest(entityName: "SSSchedule")
        
//        //create predicate
//        let predicate = NSPredicate(format: "user  == %@", self.user)
        
        //make sort descriptor
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
//        fetchRequest.predicate = predicate
        
        //create controller and return
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStackManager.sharedInstance().managedObjectContext, sectionNameKeyPath: nil, cacheName: "schedule")
        
        return fetchedResultsController
    }()
    
    lazy var shiftFetchResultsController : NSFetchedResultsController = {
        
        //create fetch request
        let fetchRequest = NSFetchRequest(entityName: "SSShift")
        
        //make sort descriptor
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        //create controller and return
        //set cacheName to "shiftCalVC" to imply shifts cache fetched in the CalendarVC
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStackManager.sharedInstance().managedObjectContext, sectionNameKeyPath: nil, cacheName: "shift")//CalVC")
        
        return fetchedResultsController
    }()
    
    lazy var notesFetchResultsController : NSFetchedResultsController = {
        
        //create fetch request
        let fetchRequest = NSFetchRequest(entityName: "SSNote")
        
        //make sort descriptor
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: true)]
        
        //create controller and return
        //set cacheName to "notesCalVC" to imply notes cache fetched in the CalendarVC
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStackManager.sharedInstance().managedObjectContext, sectionNameKeyPath: nil, cacheName: "notes")//CalVC")
        
        return fetchedResultsController
    }()
}