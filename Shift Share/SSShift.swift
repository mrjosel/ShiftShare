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
class SSShift : SSTBCellData {
    
    //shift type
    var type : SSShiftType?
    
    //protocol values set when type is set
    @objc var image : UIImage?
    @objc var title : String?
    @objc var body: String?
    
    //initializer
    init(type: SSShiftType?) {
        
        //set type, title, body, and image
        if let type = type {
            //type was set properly
            self.type = type
            self.title = SSShiftType.shiftNames[type]
            self.body = SSShiftType.shiftTimes[type]
            self.image = UIImage(named: SSShiftType.shiftNames[type]!)
        } else {

            //no type specified
            self.type = nil
            self.title = "No Shift"
            self.body = nil
            self.image = nil
        }
    }
}