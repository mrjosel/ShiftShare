//
//  SSTableViewCell.swift
//  Shift Share
//
//  Created by Brian Josel on 11/19/15.
//  Copyright © 2015 Brian Josel. All rights reserved.
//

import Foundation
import UIKit
import JTCalendar

//cell used in tableView, inherits properties from SSDayView
class SSTableViewCell: UITableViewCell {
    
    //date to track which schedule belongs
    var date : NSDate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //create imageViewframe, square size equivalent to height x height
        self.imageView?.frame = CGRect(x: 0, y: 0, width: self.frame.height, height: self.frame.height)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
}