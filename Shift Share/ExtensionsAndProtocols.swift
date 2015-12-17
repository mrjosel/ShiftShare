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

//extending UITableView to allow for deselecting all cells
extension UITableView {
    
    //runs through all cells in visible cells and sets selected parameter to false
    func deselectAllCells() {
        for cell in self.visibleCells {
            cell.selected = false
        }
    }
}

//custom color for Today's Date
extension UIColor {
    public class func todayColor() -> UIColor {
        return UIColor(red: 97/255.0, green: 194/255.0, blue: 250/255.0, alpha: 1.0)
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
    var readableDate : String  {
        get {
            return self.month + ", " + self.day + " " + self.year
        }
    }
}

//allows for easy population of tableCell data
@objc protocol SSTBCellData {
    
    //image for shift
    var image : UIImage? {get set}
    
    //string for title (shift, note title, etc)
    var title : String? {get set}
    
    //string for body/description of note
    var body : String? {get set}
    
    //returns special version specifically for editMode
    static func editMode() -> SSTBCellData
    
}