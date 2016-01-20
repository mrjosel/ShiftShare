//
//  SSScheduleManagerDelegate.swift
//  Shift Share
//
//  Created by Brian Josel on 1/19/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import Foundation

//manages when Schedule when notes are deleted or shiftType is changed to nil
//TODO: IMPLEMENT!
protocol SSScheduleManagerDelegate {
    
    func didChangeType(schedule: SSSchedule)
    
}