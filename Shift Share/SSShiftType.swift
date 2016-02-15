//
//  SSShiftType.swift
//  Shift Share
//
//  Created by Brian Josel on 12/7/15.
//  Copyright © 2015 Brian Josel. All rights reserved.
//

import Foundation
import UIKit

//enumeration for shift type
enum SSShiftType : Int, CustomStringConvertible {
    
    //image types, using ints
    case DAY = 0, NIGHT, GREEN, YELLOW, RESERVED, VACATION, NEWSHIFT
    
    //image names for use in printing and getting images
    static let shiftNames = [
        DAY : "Day",
        NIGHT : "Night",
        GREEN: "Green",
        YELLOW: "Yellow",
        RESERVED: "Reserved",
        VACATION: "Vacation",
        NEWSHIFT: "New Shift"
    ]
    
    //shift times
    //TODO: MAKE USER SELECTABLE
    static let shiftTimes = [
        DAY : "7:00AM - 7:30PM",
        NIGHT : "7:00PM - 7:30AM",
        GREEN: "Need Green Body",
        YELLOW: "Need Yellow Body",
        RESERVED: "Need Reserved Body",
        VACATION: "All Day",
        NEWSHIFT: ""
    ]
    
    //get the name of the of SSShiftImage, used in creating image and CustomStringConvertible protocol
    var description : String {
        get {
            //cast imageName to name and return, failed cast returns "DayViewImage"
            guard let name = SSShiftType.shiftNames[self] else {
                return "SSShift"
            }
            return name
        }
    }
    
    //cycles DayViewImage enum case up by 1, wraps around at the end
    mutating func cycleShift() {
        
        //get rawValue of current shift
        var rawVal = self.rawValue
        
        //if rawVal is less than 5, increment and set shift, rollover after 5
        rawVal = (rawVal < 5) ? rawVal + 1 : 0
        
        //get shift at rawValue, if no image exists, set shit to DAY
        guard let shift = SSShiftType(rawValue: rawVal) else {
            self = SSShiftType.DAY
            return
        }
        
        //shift exists for rawVal, set
        self = shift
    }
}