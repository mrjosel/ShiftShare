//
//  SSButton.swift
//  Shift Share
//
//  Created by Brian Josel on 11/23/15.
//  Copyright © 2015 Brian Josel. All rights reserved.
//

import UIKit

//enum for type of button
enum SSButtonType : Int, CustomStringConvertible {
    case EDIT = 0, TODAY, DONE, NEW
    
    static let SSButtonTypes = [
        EDIT : "Edit",
        TODAY : "Today",
        DONE : "Done",
        NEW : "New"
    ]
    
    var description : String {
        get {
            //cast imageName to name and return, failed cast returns "DayViewImage"
            guard let name = SSButtonType.SSButtonTypes[self] else {
                return "SSButtonType???"
            }
            return name
        }
    }
}


//custom button that changes states and executes different functions depending on the state
class SSButton: UIButton {
    
    //hostViewController for UIButton
    var hostViewController = UIViewController() {
        
        //add function when VC is set
        didSet {
            if hostViewController is CalendarViewController {
                self.addTarget(self.hostViewController, action: #selector(CalendarViewController.editCancelTodayButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            }
        }
    }

    //custom type for button
    var ssButtonType : SSButtonType  = .TODAY {
        
        //configure button based on which type is set
        didSet {
            switch self.ssButtonType {
            case .EDIT :
                //configure for cancel button
                self.setTitle(SSButtonType.EDIT.description, forState: UIControlState.Normal)
                //cancel and today button is never hidden
            case .TODAY :
                self.setTitle(SSButtonType.TODAY.description, forState: UIControlState.Normal)
                //cancel and today button is never hidden
            case .DONE :
                //configure for done button
                self.setTitle(SSButtonType.DONE.description, forState: UIControlState.Normal)
                //default state is hidden
            case .NEW :
                //configure for edit button
                self.setTitle(SSButtonType.NEW.description, forState: UIControlState.Normal)
                //default state is hidden
            }
        }
    }
}
