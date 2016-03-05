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
class LoginViewController: KeyboardPresentViewController, UITextFieldDelegate {
    
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
        self.loginButton.addTarget(self, action: "loginButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        self.signupButton.setTitle("Sign-Up", forState: .Normal)
        self.signupButton.addTarget(self, action: "signupButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        self.loginButtonToTextFieldSpacing = self.textFieldSpacing
        self.signupButtonToTextFieldSpacing = self.textFieldSpacing

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        
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
        let username = self.emailTextField.text
        let password = self.passwordTextField.text
        
        //TODO : construct URL for GET
        //TODO : create URL session, make request
        //TODO : parse data, get user, schedules, send to calVC
        let schedules : [SSSchedule] = []
        let userID = "00000001"
        let userIDstring = String(userID)
        var user : SSUser?
        
        //create predicate
        let predicate = NSPredicate(format: "userID  == %@", userIDstring)
        self.userFetchResultsController.fetchRequest.predicate = predicate
        
        //perform fetch
        do {
            try self.userFetchResultsController.performFetch()
        } catch {
            self.makeAlert(self, title: "No User Found", error: nil)
        }
        
        //if user is found in CoreData, fetch
        if let users = self.userFetchResultsController.fetchedObjects as? [SSUser] {
            for _user in users {
                if _user.userID == userID {
                    user = _user
                }
            }
        }
        
        //if no user found in fetch, create new user from JSON
        if user == nil {
            user = SSUser(userName: "Brian", userID: "00000001", schedules: nil, context: CoreDataStackManager.sharedInstance().managedObjectContext)
        }
        
        
        //create VCs and present
        let navVC = self.storyboard?.instantiateViewControllerWithIdentifier("NavVC") as! UINavigationController
        let calVC = navVC.viewControllers.first as! CalendarViewController
        calVC.user = user
        self.presentViewController(navVC, animated: true, completion: {
            _ in
            
            //clear out login credentials after new VC is presented
                self.emailTextField.text = ""
                self.passwordTextField.text = ""
            })
        
    }
    
    //signs user up
    func signupButtonPressed(sender: UIButton) {
        
        let signupVC = self.storyboard?.instantiateViewControllerWithIdentifier("SignUpViewController") as! SignUpViewController
        self.presentViewController(signupVC, animated: true, completion: {print("attempted to sign up")})
        

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
