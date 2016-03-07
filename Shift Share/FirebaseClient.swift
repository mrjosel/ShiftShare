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
        static let ROOTURL = "https://shiftshare.firebaseio.com"
        static let FIRSTNAME = "first_name"
        static let LASTNAME = "last_name"
        static let USERID = "user_id"
        static let DATECREATED = "date_created"
        static let SCHEDULES = "schedules"
        static let SHIFT = "shift"
        static let NOTES = "note"
    }
    
    //generic root reference to ShiftShare's database in Firebase
    var rootRef = Firebase(url: FirebaseClient.Keys.ROOTURL)
    
    //create new user
    func createNewUser(email: String, password: String, completionHandler: ((success: Bool, result: AnyObject?, error: NSError?) -> Void)) {
        self.rootRef.createUser(email, password: password, withValueCompletionBlock: {error, result in
            
            //if there is an error, pass error back to VC
            if error != nil {
                completionHandler(success: false, result: nil, error: error)
            } else {
                //pass result back via handler
                completionHandler(success: true, result: result, error: nil)
            }
        })
    }
    
    //add user to database
    func addSSUserToDatabase(user: SSUser) {
        
        //get basic params, MUST be strings
        let firstName = user.firstName
        let lastName = user.lastName
        let userID = user.userID
        let dateCreated = user.dateCreated?.toString()
        
        //TODO: ASSEMBLE BEST DICT FOR USER MODEL
        
        //assemble into dict
        let dictForID = [
            FirebaseClient.Keys.FIRSTNAME : firstName,
            FirebaseClient.Keys.LASTNAME : lastName,
            FirebaseClient.Keys.DATECREATED : dateCreated
        ]
        
        //add dict (valid JSON format) to database
        self.setValue([userID : dictForID])
    }
    
    //authenticate login credentials
    func authenticateUser(email: String, password: String, completionHandler: (success: Bool, authData: FAuthData?, error: NSError?) -> Void) {
        self.rootRef.authUser(email, password: password, withCompletionBlock: {error, authData in
            //check for error
            if let error = error {
                //TODO: PRODUCTION - BETTER ERROR HANDLING USING VARIOUS ENUM TYPES
                if let errorCode = FAuthenticationError(rawValue: error.code) {
                    switch(errorCode) {
                    case .UserDoesNotExist:
                        // Handle invalid user
                        break
                    case .InvalidEmail:
                        // Handle invalid email
                        break
                    case .InvalidPassword:
                        // Handle invalid password
                        break
                    case .EmailTaken:
                        //Handle email taken
                        break
                    case .NetworkError:
                        //Handle network error
                        break
                    case .InvalidCredentials:
                        //Handle invalid credentials
                        break
                    default:
                        break
                    }
                }
                
                //error exists, complete with handler
                completionHandler(success: false, authData: authData, error: error)
            } else {
                //no error, complete with success
                completionHandler(success: true, authData: authData, error: nil)
            }
        })
    }
    
    //convenience function for sending values to Firebase
    func setValue(validJSONobject : AnyObject?) {
        
        if let json = validJSONobject as? [String: AnyObject] {
            print("we casted")
            self.rootRef.setValue(json)
        }
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