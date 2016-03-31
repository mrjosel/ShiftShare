//
//  LoginViewController.swift
//  Shift Share
//
//  Created by Brian Josel on 3/1/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import UIKit
import CoreData
import Firebase

//VC to handle all login activity
class LoginViewController: KeyboardPresentViewController, UITextFieldDelegate, SignUpViewControllerDelegate {
    
    //outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var textFieldSpacing: NSLayoutConstraint!
    @IBOutlet weak var loginButtonToTextFieldSpacing: NSLayoutConstraint!
    @IBOutlet weak var signupButtonToTextFieldSpacing: NSLayoutConstraint!
    
    //fetched results controller
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
        
        //delegates
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        
        //setup views
        self.titleLabel.text = "ShiftShare"
        self.emailTextField.placeholder = "Email"
        self.emailTextField.clearsOnBeginEditing = true
        self.emailTextField.clearButtonMode = .WhileEditing
        self.passwordTextField.placeholder = "Password"
        self.passwordTextField.clearsOnBeginEditing = true
        self.passwordTextField.clearButtonMode = .WhileEditing
        self.passwordTextField.secureTextEntry = true
        self.loginButton.setTitle("Login", forState: .Normal)
        self.loginButton.addTarget(self, action: #selector(self.loginButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.signupButton.setTitle("Sign-Up", forState: .Normal)
        self.signupButton.addTarget(self, action: #selector(self.signupButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.loginButtonToTextFieldSpacing = self.textFieldSpacing
        self.signupButtonToTextFieldSpacing = self.textFieldSpacing
    }
    
    override func viewWillAppear(animated: Bool) {
        
        //enable buttons
        self.loginButton.enabled = true
        self.signupButton.enabled = true
        
        //hide navBar
        self.navigationController?.navigationBar.hidden = true
        
        //subscribe to keyboard notifications to allow view resizing
        self.subscribeToKeyboardNotifications()

    }
    
    override func viewWillDisappear(animated: Bool) {
        //unsubscribe to keyboard notifications to allow view resizing
        self.unsubscribeToKeyboardNotifications()
    }
    
    //logs user in, gets data via HTTP GET request, passes retrieved schedule data into calendarVC
    func loginButtonPressed(sender: UIButton) {
        print("user logging in")
        
        //get credentials
        let email = self.emailTextField.text
        let password = self.passwordTextField.text
        
        //disable buttons
        self.loginButton.enabled = false
        self.signupButton.enabled = false
        
        //attempt to authenticate user
        FirebaseClient.sharedInstance().authenticateUser(email!, password: password!, completionHandler: {success, authData, error in
            
            //failed to authenticate
            if !success {
                self.makeAlert(self, title: "Authentication Failed", error: error)
                
                //enable buttons
                self.loginButton.enabled = true
                self.signupButton.enabled = true
                
            } else {
                //successful authentication and authData
                //get user from fetch, or create user using data from server
                
                //user
                var user : SSUser
                
                //unwrap authData
                if let authData = authData {
                    
                    //get userID
                    let userID = authData.uid
                    
                    //attempt to get user from fetch
                    if let fetchedUser = self.fetchUserWithID(userID) {
                        //user found in fetch
                        user = fetchedUser
                    } else {
                        
                        //user is a ShiftShare user, not in fetch, get data from database
                        self.choiceAlert(self, title: "First Login", completionHandler: {yesButtonHit in
                            
                            if yesButtonHit {
                                //yesButton hit, exit routine and carry on creating user
                            } else {
                                //user does not wish to grab data on this phone, remove authData, exit routine
                                FirebaseClient.sharedInstance().rootRef.unauth()
                                return
                            }
                        })
                        
                        //clear out fields
                        self.emailTextField.text = ""
                        self.passwordTextField.text = ""
                        
                        //grab data from database
                        user = SSUser()
                        print("Need to create methods for getting user data, aborting")
                        abort()
                        //TODO: 1.) GET ALL USER DATA
                        //      2.) CONSTUCT SSUSER FROM DATA
                        //      3.) SAVE CONTEXT
                    }
                    //complete login
                    self.completeLoginRoutine(user)
                }
            }
        })
    }
    
    //fetch user with given ID from GET request
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
            return user
        }
        
        //no user in fetch
        return nil
    }
    
    //signs user up
    func signupButtonPressed(sender: UIButton) {
        
        let signupVC = self.storyboard?.instantiateViewControllerWithIdentifier("SignUpViewController") as! SignUpViewController
        signupVC.delegate = self
        self.presentViewController(signupVC, animated: true, completion: {print("attempted to sign up")})
        

    }
    
    //called by signup and login button routines, passes data onto calVC
    func completeLoginRoutine(user: SSUser) {
        
        //clear out login credentials after new VC is presented
        self.emailTextField.text = ""
        self.passwordTextField.text = ""
        
        //prepare for segue
        self.performSegueWithIdentifier("loginToCalVCSegue", sender: user)
    }
    
    //called when new user is created
    func didCreateNewUser(user: SSUser, email: String, password: String) {
        
        //get FAuthData for new user
        FirebaseClient.sharedInstance().authenticateUser(email, password: password, completionHandler: {success, authData, error in
            if success {
                
                //add user to database
                FirebaseClient.sharedInstance().addSSUserToDatabase(user)
                
                //finish login routine with user
                self.completeLoginRoutine(user)
            } else {
                self.makeAlert(self, title: "Authentication Failed", error: error!)
            }
        })
    }
    
    //handle segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "loginToCalVCSegue" {
        //create VCs and present
        let calVC = segue.destinationViewController as! CalendarViewController
        
        //pass in user, clear out user defaults
        calVC.user = sender as! SSUser
        calVC.userDefaults.removeObjectForKey("selectedDate")
        }
    }
    
    //what to do when return key is pressed
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField.text != "" {
            //if textField is userName, progress to password textField
            if textField == self.emailTextField {
                self.passwordTextField.becomeFirstResponder()

            } else {
                //if textField is password, hit login button
                self.loginButtonPressed(self.loginButton)
                
                //remove keyboard
                textField.resignFirstResponder()
            }
            //rmeove keyboard since text is not nil
            return true
        }
        //text is "", do not allow return
        return false
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
