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
class LoginViewController: UIViewController, UITextFieldDelegate {
    
    //outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextFeld: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    //for keyboard adjustments (used in ExtensionsAndProtocols.swift)
    var keyboardAdjusted = false
    var lastKeyboardOffset : CGFloat = 0.0
    var tapRecognizer: UITapGestureRecognizer? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    override func viewDidAppear(animated: Bool) {
        //hide navBar
        self.navigationController?.navigationBar.hidden = true
    }
    
    //logs user in
    func loginButtonPressed() {
        print("user logging in")
    }
    
    //signs user up
    func signupButtonPressed() {
        print("new user signing up")
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
