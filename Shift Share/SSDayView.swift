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
    
    // Only override drawRect: if you perform custom drawing. //Stock comment from Xcode declaration
    // An empty implementation adversely affects performance during animation. //Stock comment from Xcode declaration
    
    //image displayed for sun, moon, other events
    //TODO: CONSIDER RENAMING
    var shiftImageView: UIImageView?
        
    //actual dayViewImage, use to fill image in above shiftImageView
    var shift : SSShift
    
    //notes
    var notes : [SSNote]
    
    //initializers
    override init(frame: CGRect) {
        //set image to "No Shift", and notes to []
        self.shift = SSShift.NOSHIFT
        self.notes = []
        
        //super init
        super.init(frame: frame)
        
    }
    
    //required init from super
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //super method for UI initialization, add SSDV specific UI calls here
    override func commonInit() {
        super.commonInit()
    }
    
    //cycles DayViewImage enum case up by 1, wraps around at the end
    func cycleDayViewImage() {
        
        //get rawValue of current shift
        var rawVal = self.shift.rawValue
        
        //if rawVal is less than 6, increment and set shift, rollover after 6
        rawVal = (rawVal < 6) ? rawVal + 1 : 0
        
        //get shift at rawValue, if no image exists, set shit to NOSHIFT
        guard let shift = SSShift(rawValue: rawVal) else {
            self.shift = SSShift.NOSHIFT
            return
        }
        
        //shift exists for rawVal, set
        self.shift = shift
    }
}
