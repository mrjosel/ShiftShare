//
//  ExtensionsAndProtocols.swift
//  Shift Share
//
//  Created by Brian Josel on 11/20/15.
//  Copyright © 2015 Brian Josel. All rights reserved.
//

import Foundation
import UIKit

//extending UITableView to allow for delecting all cells
extension UITableView {
    
    //runs through all cells in visible cells and sets selected parameter to false
    func deselectAllCells() {
        for cell in self.visibleCells {
            cell.selected = false
        }
    }
}