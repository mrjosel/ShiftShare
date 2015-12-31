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
    var ssDVImageView: UIImageView!
    
    var doubleTapGesture: UITapGestureRecognizer!
        
    override func layoutSubviews() {
        super.layoutSubviews()

        //override placement and font-size of textLabel
        self.textLabel.frame = CGRect(x: 5, y: 5, width: self.frame.width / 4, height: self.frame.height / 4)
        self.textLabel.font = UIFont(name: ".SFUIText-Regular", size: 9.0)
        
        //override placement of dotView
        self.dotView.frame.origin = CGPoint(x: 5, y: self.frame.height - (self.dotView.frame.height + 5))
        
        //layout the imageView
        let scaleFactor = CGFloat(0.7)
        let originOffset = (1 - scaleFactor) / 2
        let imgSize = CGSize(width: self.frame.width * scaleFactor, height: self.frame.height * scaleFactor)
        let imgOrigin = CGPoint(x: self.frame.width * originOffset, y: self.frame.height * originOffset)
        self.ssDVImageView.frame = CGRect(origin: imgOrigin, size: imgSize)
        
    }
    
    //super method for UI initialization, add SSDV specific calls here
    override func commonInit() {
        super.commonInit()
        
        //add border around dayViews
        self.layer.borderColor = UIColor.blackColor().CGColor
        self.layer.borderWidth = 0.25
        
        //remove circleView
        self.circleView.removeFromSuperview()
        
        //create ssDVImageView
        self.ssDVImageView = UIImageView()
        self.insertSubview(self.ssDVImageView, atIndex: 0)
        self.ssDVImageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.ssDVImageView.hidden = true
        self.ssDVImageView.layer.rasterizationScale = UIScreen.mainScreen().scale
        self.ssDVImageView.layer.shouldRasterize = true
        
        //set up doubleTap Gesture
        self.doubleTapGesture = UITapGestureRecognizer(target: self, action: "handleDoubleTap:")
        self.doubleTapGesture.numberOfTapsRequired = 2
        self.addGestureRecognizer(self.doubleTapGesture)
        
        //dotView default is hidden
        self.dotView.hidden = true
        
    }
    
    //invoke double tap gesture
    func handleDoubleTap(sender: UITapGestureRecognizer) {
        
        //alert the delegate
        self.manager?.delegateManager.didDoubleTapDayView(self)

    }
}
