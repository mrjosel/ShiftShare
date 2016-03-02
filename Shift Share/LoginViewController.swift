//
//  LoginViewController.swift
//  Shift Share
//
//  Created by Brian Josel on 3/1/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import UIKit
import CoreData

//VC to handle all login activity
class LoginViewController: KeyboardPresentViewController, UITextFieldDelegate {
    
    //outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextFeld: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!

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
    
    //logs user in
    func loginButtonPressed() {
        print("user logging in")
    }
    
    //signs user up
    func signupButtonPressed() {
        print("new user signing up")
    }
    
    //what to do when return key is pressed
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
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
