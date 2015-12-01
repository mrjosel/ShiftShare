//
//  SSDayView.swift
//  Shift Share
//
//  Created by Brian Josel on 11/16/15.
//  Copyright © 2015 Brian Josel. All rights reserved.
//

import UIKit
import JTCalendar
import QuartzCore

//custom class of JTCalendarDayView with UIImageView? parameter and method to cycle through images
class SSDayView: JTCalendarDayView {
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    
    //image displayed for sun, moon, other events
    //TODO: WHY IS IMAGE NIL??? WHY DOESNT IMAGE SHOW???
    var ssDVImageView: UIImageView!
        
    //schedule for the day
    var schedule : SSScheduleForDay? {
        didSet {
            
            //get image if it exists
            if let image = self.schedule?.shift.image {
                print("image is not nil, setting to \(image) for \(date.readableDate())")
                self.ssDVImageView = UIImageView(image: image)
                self.ssDVImageView.backgroundColor = UIColor.blackColor()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //override placement and font-size of textLabel
        self.textLabel.frame = CGRect(x: 5, y: 5, width: self.frame.width / 4, height: self.frame.height / 4)
        self.textLabel.font = UIFont(name: ".SFUIText-Regular", size: 10.0)
        
        //layout the imageView
        self.ssDVImageView = UIImageView(frame: self.frame)
        self.ssDVImageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.sendSubviewToBack(self.ssDVImageView!)
        
    }
    
    //super method for UI initialization, add SSDV specific calls here
    override func commonInit() {
        
        super.commonInit()
        
        //add border around dayViews
        self.layer.borderColor = UIColor.blackColor().CGColor
        self.layer.borderWidth = 0.25
        
        //remove circleView
        self.circleView.removeFromSuperview()
        self.dotView.removeFromSuperview()
    }
}
