//
//  SSCalendarDelegate.swift
//  Shift Share
//
//  Created by Brian Josel on 12/23/15.
//  Copyright © 2015 Brian Josel. All rights reserved.
//

import Foundation
import JTCalendar

//custom protocol to allow for double tapping day views
protocol SSCalendarDelegate: JTCalendarDelegate {
    
    //allows for double touch gestures
    func calendar(calendar: JTCalendarManager!, didDoubleTapDayView dayView: UIView!) -> Void

}