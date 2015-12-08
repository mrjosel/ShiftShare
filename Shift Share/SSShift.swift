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
    var type : SSShiftType
    
    //protocol values set when type is set
    var image : UIImage?
    var title : String?
    var body: String?
    
    //initializer
    init(type: SSShiftType) {
        
        //set type, title, body, and image
        self.type = type
        self.title = SSShiftType.shiftNames[type]
        self.body = SSShiftType.shiftTimes[type]
        self.image = UIImage(named: SSShiftType.shiftNames[type]!)
    }
}