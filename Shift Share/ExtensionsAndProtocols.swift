//
//  ExtensionsAndProtocols.swift
//  Shift Share
//
//  Created by Brian Josel on 11/20/15.
//  Copyright © 2015 Brian Josel. All rights reserved.
//
//  Extensions of existing CocoaTouch and custom classes as well as custom protocols


import Foundation
import UIKit
import JTCalendar
import CoreData

//extending UITableView to allow for deselecting all cells
extension UITableView {
    
    //runs through all cells in visible cells and sets selected parameter to false
    func deselectAllCells() {
        for cell in self.visibleCells {
            cell.selected = false
        }
    }
}

//custom color for Today's Date
extension UIColor {
    public class func todayColor() -> UIColor {
        return UIColor(red: 97/255.0, green: 194/255.0, blue: 250/255.0, alpha: 1.0)
    }
}

//allows easily getting date information in readable text, or for use in keying dicts
extension NSDate {
    
    var keyFromDate: String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return dateFormatter.stringFromDate(self)
    }
    
    var month: String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.stringFromDate(self)
    }
    
    var day: String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd"
        //helps display days at 7, 8, 9 instead of 07, 08, 09
        if let intDay = Int(dateFormatter.stringFromDate(self)) {
            return String(intDay)
        }
        return dateFormatter.stringFromDate(self)
        
    }
    
    var year: String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.stringFromDate(self)
    }
    
    //outputs readable date
    //TODO: MAKE PRINTOUT DIFFERENT BY COUNTRY?
    var readableDate : String  {
        get {
            return self.month + " " + self.day + ", " + self.year
        }
    }
}

//allows all VCs to use custom alert when saving context fails (and other alerts)
extension UIViewController {
    
    //handler for OK button depending on VC
    func makeAlert(hostVC: UIViewController, title: String, error: NSError?) -> Void {
        
        //handler
        var handler : ((UIAlertAction) -> Void)?
        
        //text to be displated
        var messageText: String!
        
        if let error = error {
            messageText = error.localizedDescription
        } else {
            messageText = "Press OK to Continue"
        }
        
        //create handler, always nil unless sent by menuVC
        if hostVC is MenuViewController {
            handler = {alert in
                hostVC.dismissViewControllerAnimated(true, completion: nil)
            }
        } else {
            handler = nil
        }
        
        //create UIAlertVC
        let alertVC = UIAlertController(title: title, message: messageText, preferredStyle: UIAlertControllerStyle.Alert)
        
        //create action
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: handler)
        
        //add actions to alertVC
        alertVC.addAction(ok)
        dispatch_async(dispatch_get_main_queue(), {
            //present alertVC
            hostVC.presentViewController(alertVC, animated: true, completion: nil)
        })
    }
}

//allows for easy population of tableCell data
protocol SSScheduleItem : NSObjectProtocol {
    
    //image for shift
    var imageName : String? {get}
    
    //string for title (shift, note title, etc)
    var title : String? {get set}
    
    //string for body/description of note
    var body : String? {get set}
    
    //schedule for data
    var schedule : SSSchedule? {get set}
    
}

//handles passing of data during signup
protocol SignUpViewControllerDelegate : NSObjectProtocol {
    
    
    //informs delegate new user was created
    func didCreateNewUser(user: SSUser, email: String, password: String) -> Void
}