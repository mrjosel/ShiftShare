//
//  FirebaseClient.swift
//  Shift Share
//
//  Created by Brian Josel on 3/4/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import Foundation
import Firebase

//manages all RESTful activity via Firebase
class FirebaseClient {
    
    //commonly used keys
    struct Keys {
        static let rootURL = "https://shiftshare.firebaseio.com"
    }
    
    //generic root reference to ShiftShare's database in Firebase
    var rootRef = Firebase(url: FirebaseClient.Keys.rootURL)
    
    //Firebase reference for logging in users
    var loginRef = Firebase(url: FirebaseClient.Keys.rootURL)
    
    
    //create new user
    func createNewUser(email: String, password: String, completionHandler: ((success: Bool, userID: AnyObject?, error: NSError?) -> Void)) {
        self.loginRef.createUser(email, password: password, withValueCompletionBlock: {error, result in
            
            //if there is an error, pass error back to VC
            if error != nil {
                completionHandler(success: false, userID: nil, error: error)
            } else {
                let uid = result["uid"] as? String
                completionHandler(success: true, userID: uid, error: nil)
            }
        })
    }
    
    //convenience function for sending values to Firebase
    func setValue(validJSONobject : String) {
        self.rootRef.setValue(validJSONobject)
    }
    
    //convenience function for reading data and reacting to changes
    func observeEventType(eventType: FEventType, withBlock block: ((FDataSnapshot!) -> Void)!) {
        self.rootRef.observeEventType(eventType, withBlock: block)
    }
    
    //Firebase Singleton
    class func sharedInstance() -> FirebaseClient {
        struct Singleton {
            static let instance = FirebaseClient()
        }
        return Singleton.instance
    }
}