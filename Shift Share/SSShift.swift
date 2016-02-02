//
//  SSShift.swift
//  Shift Share
//
//  Created by Brian Josel on 11/19/15.
//  Copyright © 2015 Brian Josel. All rights reserved.
//

import Foundation
import UIKit


//class for actual shift
class SSShift : NSObject, SSTBCellData {
    
    //shift type
    var type : SSShiftType? {
        didSet {

            //alert manager
            if let schedule = self.schedule, manager = schedule.manager {
                manager.didChangeShiftOrType(schedule)
            }
        }
    }
    
    //protocol values set when type is set
    var image : UIImage?
    var title : String?
    var body: String?
    
    //schedule associated with shift
    var schedule : SSSchedule?
    
    //initializer
    init(type: SSShiftType) {
        
            //type was set properly
            self.type = type
            self.title = SSShiftType.shiftNames[type]
            self.body = SSShiftType.shiftTimes[type]
            self.image = UIImage(named: SSShiftType.shiftNames[type]!)
    }
    
    //empty initializer
    override init() {
        
        //no type specified
        self.type = nil
        self.title = "No Shift"
        self.body = nil
        self.image = nil
    }
}