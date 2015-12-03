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
    var ssDVImageView: UIImageView!
        
    //schedule for the day
    var schedule : SSScheduleForDay?
    
    override func layoutSubviews() {
        super.layoutSubviews()

        //override placement and font-size of textLabel
        self.textLabel.frame = CGRect(x: 5, y: 5, width: self.frame.width / 4, height: self.frame.height / 4)
        self.textLabel.font = UIFont(name: ".SFUIText-Regular", size: 10.0)
        
        //layout the imageView
        self.ssDVImageView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        
    }
    
    //super method for UI initialization, add SSDV specific calls here
    override func commonInit() {
        super.commonInit()
        
        //add border around dayViews
        self.layer.borderColor = UIColor.blackColor().CGColor
        self.layer.borderWidth = 0.25
        
        //remove circleView
//        self.circleView.removeFromSuperview()
        self.dotView.removeFromSuperview()
        
        //layout ssDVImageView
        self.ssDVImageView = UIImageView()
        self.addSubview(self.ssDVImageView)
        self.sendSubviewToBack(self.ssDVImageView)
        self.ssDVImageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.ssDVImageView.backgroundColor = UIColor.redColor() //TODO: DEBUG REMOVE LATER
        self.ssDVImageView.hidden = true
        self.ssDVImageView.layer.rasterizationScale = UIScreen.mainScreen().scale
        self.ssDVImageView.layer.shouldRasterize = true

        
    }
}
