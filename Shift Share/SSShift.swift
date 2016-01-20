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
            //reconfig with new type
            self.reload()
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
    
    //config function switching all params to given SSShiftType
    func reload() {
        
        //type is nil, clear out all data
        guard let type = self.type else {
            self.type = nil
            self.title = "No Shift"
            self.body = nil
            self.image = nil
            return
        }
        
        //type was set properly
        self.title = SSShiftType.shiftNames[type]
        self.body = SSShiftType.shiftTimes[type]
        if let name = SSShiftType.shiftNames[type] {
            self.image = UIImage(named: name)
        } else {
            self.image = nil
        }
    }
}