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
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextFeld: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var textFieldSpacing: NSLayoutConstraint!
    @IBOutlet weak var loginButtonToTextFieldSpacing: NSLayoutConstraint!
    @IBOutlet weak var signupButtonToTextFieldSpacing: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //delegates
        self.userNameTextField.delegate = self
        self.passwordTextFeld.delegate = self
        
        //setup views
        self.titleLabel.text = "ShiftShare"
        self.userNameTextField.placeholder = "Username"
        self.userNameTextField.clearsOnBeginEditing = true
        self.userNameTextField.clearButtonMode = .WhileEditing
        self.passwordTextFeld.placeholder = "Password"
        self.passwordTextFeld.clearsOnBeginEditing = true
        self.passwordTextFeld.clearButtonMode = .WhileEditing
        self.loginButton.setTitle("Login", forState: .Normal)
        self.loginButton.actionsForTarget("loginButtonTouched", forControlEvent: .TouchUpInside)
        self.signupButton.setTitle("Sign-Up", forState: .Normal)
        self.signupButton.actionsForTarget("signupButtonPressed", forControlEvent: .TouchUpInside)
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
    func loginButtonPressed() {
        print("user logging in")
        
        //get credentials
        let username = self.userNameTextField.text
        let password = self.passwordTextFeld.text
        
        //TODO : construct URL for GET
        //TODO : create URL session, make request
        //TODO : parse data, get user, schedules, send to calVC
        let schedules : [SSSchedule] = []
        let user = SSUser(userName: "Brian", userID: 000000001, schedules: nil, context: CoreDataStackManager.sharedInstance().managedObjectContext)
        

        //create VCs and present
        let navVC = self.storyboard?.instantiateViewControllerWithIdentifier("NavVC") as! UINavigationController
        let calVC = navVC.viewControllers.first as! CalendarViewController
        calVC.user = user
        self.presentViewController(navVC, animated: true, completion: {
            _ in
            
            //clear out login credentials after new VC is presented
                self.userNameTextField.text = ""
                self.passwordTextFeld.text = ""
            })
        
    }
    
    //signs user up
    func signupButtonPressed() {
        print("new user signing up")
        //TODO: CREATE NEW SIGNUPVC, COMPARE TO ON THE MAP PROJECT
    }
    
    //what to do when return key is pressed
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField.text != "" {
            //if textField is userName, progress to password textField
            if textField == self.userNameTextField {
                self.passwordTextFeld.becomeFirstResponder()

            } else {
                //if textField is password, hit login button
                self.loginButtonPressed()
                
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
