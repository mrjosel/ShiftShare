//
//  SSScheduleManagerDelegate.swift
//  Shift Share
//
//  Created by Brian Josel on 1/19/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import Foundation

//manages when Schedule when notes are deleted or shiftType is changed to nil
protocol SSScheduleManagerDelegate {
    
    //perform when shift type changes
    func didChangeShiftType(schedule: SSSchedule) -> Void
    
    //perform when any aspect of notes changes (title, body)
    func didChangeNoteContents(schedule: SSSchedule) -> Void
    
    //after the above are performed, invoke this method, intent is that if shift and [notes] are nil, manager should remove schedule from memory
    func checkForShiftOrNotes(schedule: SSSchedule) -> Void
}