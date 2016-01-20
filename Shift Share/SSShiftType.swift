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
    case DAY = 0, NIGHT, GREEN, YELLOW, RESERVED, VACATION
    
    //image names for use in printing and getting images
    static let shiftNames = [
        DAY : "Day",
        NIGHT : "Night",
        GREEN: "Green",
        YELLOW: "Yellow",
        RESERVED: "Reserved",
        VACATION: "Vacation"
    ]
    
    //shift times
    //TODO: MAKE USER SELECTABLE
    static let shiftTimes = [
        DAY : "7:00AM - 7:30PM",
        NIGHT : "7:00PM - 7:30AM",
        GREEN: "Need Green Body",
        YELLOW: "Need Yellow Body",
        RESERVED: "Need Reserved Body",
        VACATION: "All Day"
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
}