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
    case CANCEL = 0, TODAY, DONE, EDIT
    
    static let SSButtonTypes = [
        CANCEL : "Cancel",
        TODAY : "Today",
        DONE : "Done",
        EDIT : "Edit"
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

    
    //custom type for button
    var ssButtonType : SSButtonType  = .TODAY {
        
        //configure button based on which type is set
        didSet {
            switch self.ssButtonType {
            case .CANCEL :
                //configure for cancel button
                self.setTitle(SSButtonType.CANCEL.description, forState: UIControlState.Normal)
                //cancel and today button is never hidden
                self.hidden = false
            case .TODAY :
                self.setTitle(SSButtonType.TODAY.description, forState: UIControlState.Normal)
                //cancel and today button is never hidden
                self.hidden = false
            case .DONE :
                //configure for done button
                self.setTitle(SSButtonType.DONE.description, forState: UIControlState.Normal)
                //default state is hidden
                self.hidden = true
            case .EDIT :
                //configure for edit button
                self.setTitle(SSButtonType.EDIT.description, forState: UIControlState.Normal)
                //default state is hidden
                self.hidden = true
            default :
                //unrecognized state
                break
            }
        }
    }
}
