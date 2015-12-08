//
//  ExtensionsAndProtocols.swift
//  Shift Share
//
//  Created by Brian Josel on 11/20/15.
//  Copyright © 2015 Brian Josel. All rights reserved.
//

import Foundation
import UIKit
import JTCalendar

//extending UITableView to allow for delecting all cells
extension UITableView {
    
    //runs through all cells in visible cells and sets selected parameter to false
    func deselectAllCells() {
        for cell in self.visibleCells {
            cell.selected = false
        }
    }
}

//allows easily getting date information in readable text
extension NSDate {
    var month: String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.stringFromDate(self)
    }
    
    var day: String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd"
        return dateFormatter.stringFromDate(self)
    }
    
    var year: String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.stringFromDate(self)
    }
    
    //outputs readable date
    //TODO: MAKE PRINTOUT DIFFERENT BY COUNTRY?
    func readableDate() -> String {
        return self.month + ", " + self.day + " " + self.year
    }
}

//allows for easy population of tableCell data
protocol SSTBCellData {
    
    //image for shift
    var image : UIImage? {get set}
    
    //string for title (shift, note title, etc)
    var title : String? {get set}
    
    //string for body/description of note
    var body : String? {get set}
    
}