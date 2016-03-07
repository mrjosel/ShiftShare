//
//  WelcomeViewController.swift
//  Shift Share
//
//  Created by Brian Josel on 3/6/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import UIKit
import Firebase
import CoreData

//first viewContoller when app launches
//checks for already logged in user
//if not logged in, loads loginVC
//if valid token, proceeds to calVC
class WelcomeViewController: UIViewController {

    //outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    //time delay
    var dispatchTime :  dispatch_time_t?
    
    //fetched results controller, no need for delegate methods, VC never changes content or responds to changes
    lazy var userFetchResultsController : NSFetchedResultsController = {
        
        //create fetch request
        let fetchRequest = NSFetchRequest(entityName: "SSUser")
        
        //make sort descriptor
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "userID", ascending: true)]
        
        //create controller and return
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStackManager.sharedInstance().managedObjectContext, sectionNameKeyPath: nil, cacheName: "user")
        
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //DEBUG
        FirebaseClient.sharedInstance().loginRef.unauth()
        
        //actual delay
        let seconds = 2.0
        let delay = seconds * Double(NSEC_PER_SEC) //nanoseconds per seconda
        self.dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        //setup views
        self.titleLabel.text = "ShiftShare"
        self.messageLabel.text = ""
    
    }
    
    override func viewWillAppear(animated: Bool) {
        //hide navBar
        self.navigationController?.navigationBar.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        //check for logged in users, will progress to loginVC or calVC depending on whether user is logged in or not
        self.checkForLoggedInUser()
    }
    
    //checks if user is logged in
    func checkForLoggedInUser() {
        
        //check for valid FAuthObject
        if FirebaseClient.sharedInstance().loginRef.authData == nil {
            
            //no auth data, proceed to loginVC
            dispatch_async(dispatch_get_main_queue(), {self.messageLabel.text = "Loading..."})
            dispatch_after(self.dispatchTime!, dispatch_get_main_queue(), {
                self.performSegueWithIdentifier("loginVCSegue", sender: nil)
            })
            
        } else {
            //authData exists, send to calVC
            let authData = FirebaseClient.sharedInstance().loginRef.authData
            let userID = authData.uid
            if let user = self.fetchUserWithID(userID) {
                dispatch_async(dispatch_get_main_queue(), {self.messageLabel.text = "Loading Calendar..."})
                dispatch_after(self.dispatchTime!, dispatch_get_main_queue(), {
                        self.performSegueWithIdentifier("alreadyLoggedInSegue", sender: user)
                    })
            } else {
                //authData exists for ID, but user not found, this is error due to not having logged off but data missing, logoff to fix
                self.makeAlert(self, title: "User Not Found", error: nil)
                FirebaseClient.sharedInstance().loginRef.unauth()
                self.performSegueWithIdentifier("loginVCSegue", sender: nil)
            }
        }
    }
    
    //prepare for segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        //check for segueID
        if segue.identifier == "loginVCSegue" {

            let _ = segue.destinationViewController as! LoginViewController
        } else if segue.identifier == "alreadyLoggedInSegue" {
            
            //cast sender as SSUser
            if let user = sender as? SSUser {
                let calVC = segue.destinationViewController as! CalendarViewController
                calVC.user = user
            }
        }
    }
    
    //gets user with ID from fetch
    func fetchUserWithID(userID: String) -> SSUser? {
        
        //create predicate
        let predicate = NSPredicate(format: "userID  == %@", userID)
        self.userFetchResultsController.fetchRequest.predicate = predicate
        
        //perform fetch
        do {
            try self.userFetchResultsController.performFetch()
        } catch {
            self.makeAlert(self, title: "Disk Error", error: nil)
        }
        
        //get user in fetch with the given ID
        if let users = self.userFetchResultsController.fetchedObjects as? [SSUser], let user = users.first {
            if user.userID == userID {
                //user matches ID, return
                return user
            }
        }
        //user not found, return nil
        return nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
