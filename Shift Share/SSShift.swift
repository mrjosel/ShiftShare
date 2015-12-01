//
//  SSShift.swift
//  Shift Share
//
//  Created by Brian Josel on 11/19/15.
//  Copyright © 2015 Brian Josel. All rights reserved.
//

import Foundation
import JTCalendar
import UIKit

//enumeration for images that are displayed in dayViews for sun, moon, and others
enum SSShift : Int, CustomStringConvertible {
    
    //image types, using ints
    case NOSHIFT = 0, DAY, NIGHT, GREEN, YELLOW, RESERVED, VACATION
    
    //image names for use in printing and getting images
    static let shiftNames = [
        NOSHIFT : "No Shift",
        DAY : "Day",
        NIGHT : "Night",
        GREEN: "Green",
        YELLOW: "Yellow",
        RESERVED: "Reserved",
        VACATION: "Vacation"
    ]
    
    //get the name of the of SSShiftImage, used in creating image and CustomStringConvertible protocol
    var description : String {
        get {
            //cast imageName to name and return, failed cast returns "DayViewImage"
            guard let name = SSShift.shiftNames[self] else {
                return "SSShift"
            }
            return name
        }
    }
    
    //returns image from bundle
    var image : UIImage? {
        get {
            //return image with description, if no image exists for description, return nil
            guard let image = UIImage(named: self.description) else {
                return nil
            }
            return image
        }
    }
    
    //cycles DayViewImage enum case up by 1, wraps around at the end
    //TODO: DEBUG, REMOVE LATER
    mutating func cycleShift() {
        
        //get rawValue of current shift
        var rawVal = self.rawValue
        
        //if rawVal is less than 6, increment and set shift, rollover after 6
        rawVal = (rawVal < 6) ? rawVal + 1 : 0
        
        //get shift at rawValue, if no image exists, set shit to NOSHIFT
        guard let shift = SSShift(rawValue: rawVal) else {
            self = SSShift.NOSHIFT
            return
        }
        
        //shift exists for rawVal, set
        self = shift
    }
}