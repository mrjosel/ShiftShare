//
//  ShiftShareDayView.swift
//  Shift Share
//
//  Created by Brian Josel on 11/16/15.
//  Copyright © 2015 Brian Josel. All rights reserved.
//

import UIKit
import JTCalendar

class ShiftShareDayView: JTCalendarDayView {

    var dayImage: UIImageView?
    // Only override drawRect: if you perform custom drawing. //Stock comment from Xcode declaration
    // An empty implementation adversely affects performance during animation. //Stock comment from Xcode declaration
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        self.commonInit()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func commonInit() {
        super.commonInit()
        self.backgroundColor = UIColor.greenColor()
    }
}
