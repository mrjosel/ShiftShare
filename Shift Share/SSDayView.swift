//
//  SSDayView.swift
//  Shift Share
//
//  Created by Brian Josel on 11/16/15.
//  Copyright © 2015 Brian Josel. All rights reserved.
//

import UIKit
import JTCalendar

//custom class of JTCalendarDayView with UIImageView? parameter and method to cycle through images
class SSDayView: JTCalendarDayView {
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    
    //image displayed for sun, moon, other events
    var ssDVImageView: UIImageView?
        
    //schedule for the day
    var schedule : SSScheduleForDay? {
        didSet {
            
            //get image if it exists
            if let image = self.schedule?.shift.image {
                self.ssDVImageView?.image = image
            }
        }
    }
    
    //super method for UI initialization, add SSDV specific calls here
    override func commonInit() {
        
        super.commonInit()
    }
}
