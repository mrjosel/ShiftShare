//
//  SSDoubleTapCell.swift
//  Shift Share
//
//  Created by Brian Josel on 12/31/15.
//  Copyright © 2015 Brian Josel. All rights reserved.
//

import Foundation
import UIKit
import JTCalendar

//type to switch population
enum SSScheduleDoubleTapCellType {
    case EXPAND, COLLAPSE
}
class SSScheduleDoubleTapCell: SSTBCellData {
    
    //vars for protocol conformance
    var image : UIImage?
    var title : String?
    var body : String?
    
    //schedule associated with data
    var schedule : SSSchedule?
    
    //type
    var type : SSScheduleDoubleTapCellType {
        didSet {
            switch type {
            case .EXPAND:
                self.title = "Double Tap Day in Calendar to Expand"
            case .COLLAPSE:
                self.title = "Double Tap Day in Calendar to Collapse"
            }
        }
    }
    
    init(type: SSScheduleDoubleTapCellType) {
        self.type = type
        self.image = nil
        self.body = nil
        switch type {
        case .EXPAND:
            self.title = "Double Tap Day in Calendar to Expand"
        case .COLLAPSE:
            self.title = "Double Tap Day in Calendar to Collapse"
        }
    }
    
    //empty initializer
    init() {
        self.type = .EXPAND //default is expand
        self.image = nil
        self.body = nil
        self.title = nil
    }
}