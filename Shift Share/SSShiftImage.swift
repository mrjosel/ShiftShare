//
//  SSShiftImage.swift
//  Shift Share
//
//  Created by Brian Josel on 11/19/15.
//  Copyright © 2015 Brian Josel. All rights reserved.
//

import Foundation
import JTCalendar
import UIKit

//enumeration for images that are displayed in dayViews for sun, moon, and others
enum SSShiftImage : Int, CustomStringConvertible {
    
    //image types, using ints
    case NOIMAGE = 0, SUN, MOON, GREEN, YELLOW, RESERVED, VACATION
    
    //image names for use in printing and getting images
    static let imageNames = [
        NOIMAGE : "No Image",
        SUN : "Sun",
        MOON : "Moon",
        GREEN: "Green",
        YELLOW: "Yellow",
        RESERVED: "Reserved",
        VACATION: "Vacation"
    ]
    
    //get the name of the of SSShiftImage, used in creating image and CustomStringConvertible protocol
    var description : String {
        get {
            //cast imageName to name and return, failed cast returns "DayViewImage"
            guard let name = SSShiftImage.imageNames[self] else {
                return "SSShiftImage"
            }
            return name
        }
    }
    
    //returns image from bundle
    var image : UIImage {
        get {
            //return image with description, if no image exists for description, return empty image
            guard let image = UIImage(named: self.description) else {
                return UIImage()
            }
            return image
        }
    }
}