//
//  SignUpViewController.swift
//  Shift Share
//
//  Created by Brian Josel on 3/5/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import UIKit

class SignUpViewController: KeyboardPresentViewController, UITextFieldDelegate {

    //outlets
    @IBOutlet weak var fieldsView: UIView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var createNewUserButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //setup views
        self.firstNameTextField.placeholder = "First Name"
        self.firstNameTextField.clearButtonMode = .WhileEditing
        self.lastNameTextField.placeholder = "Last Name"
        self.lastNameTextField.clearButtonMode = .WhileEditing
        self.emailTextField.placeholder = "Email"
        self.emailTextField.clearButtonMode = .WhileEditing
        self.passwordTextField.placeholder = "Password"
        self.passwordTextField.clearButtonMode = .WhileEditing
        self.passwordTextField.secureTextEntry = true
        self.createNewUserButton.setTitle("Join ShiftShare", forState: .Normal)
        self.createNewUserButton.addTarget(self, action: "createNewUser:", forControlEvents: .TouchUpInside)
        self.cancelButton.setTitle("Cancel", forState: .Normal)
        self.cancelButton.addTarget(self, action: "cancelButtonPressed:", forControlEvents: .TouchUpInside)
        
        //delegates
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        
    }
    
    //creates new user based off input params
    func createNewUser(sender: UIButton, completionHandler: (success: Bool, userID: String?, error: NSError?) -> Void) {
        
        //migrate this to other viewController
        FirebaseClient.sharedInstance().createNewUser(self.emailTextField.text!, password: self.passwordTextField.text!, completionHandler: {success, userID, error in
            
            //check for success, if false, make alert, if true carry on new user routine
            if !success {
                self.makeAlert(self, title: "Sign-Up Failed", error: error)
            } else {
                //ensure userID is not nil, create new SSUser using
                if let userID = userID as? String {
                    print("Successful, userID = \(userID)")
                }
            }
        })
    }
    
    //cancels and exists VC
    func cancelButtonPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: {
            self.firstNameTextField.text = ""
            self.lastNameTextField.text = ""
            self.emailTextField.text = ""
            self.passwordTextField.text = ""
        })
    }
    
    //get keyboard notifications
    override func viewWillAppear(animated: Bool) {
        self.subscribeToKeyboardNotifications()
    }
    
    //remove keyboard notifications
    override func viewWillDisappear(animated: Bool) {
        self.unsubscribeToKeyboardNotifications()
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
