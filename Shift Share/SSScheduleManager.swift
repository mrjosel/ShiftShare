//
//  SSScheduleManager.swift
//  Shift Share
//
//  Created by Brian Josel on 1/21/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import Foundation
import JTCalendar
import UIKit

//class to manage all schedules when one or parameters change
class SSScheduleManager: SSScheduleManagerDelegate {
    
    //when shift type changes, make all necessary changes in shift parameters
    func didChangeShiftOrType(schedule: SSSchedule) {

        //get shift, if shift is nil return, if type is nil, set shift to nil
        guard let shift = schedule.shift, type = shift.type else {
            schedule.shift = nil
            return
        }
        
        //type is valid, set title, image, body apprropriately
        shift.title = SSShiftType.shiftNames[type]
        shift.body = SSShiftType.shiftTimes[type]
        if let image = UIImage(named: type.description) {
            shift.image = image
        } else {
            shift.image = nil
        }
        
        //check for shift or notes
        self.checkForShiftOrNotes(schedule)
        
    }
    
    //when any aspect of note changes, make appropriate changes in note, remove from array if nil
    func didChangeNoteOrContents(schedule: SSSchedule) {
        
        //if notes is [], set to nil
        if let notes = schedule.notes where notes.count == 0 {
            schedule.notes = nil
        }
        
        //check for shift or notes
        self.checkForShiftOrNotes(schedule)
    }
    
    //if shift AND [notes] are nil, clear from memory
    func checkForShiftOrNotes(schedule: SSSchedule) {

        if (schedule.shift == nil && (schedule.notes == nil || schedule.notes!.count == 0)) {
            
            //shift is nil, notes are nil or empty, remove schedule from memory
            guard let date = schedule.date else {
                
                //no date is an error, return
                return
            }
            
            //remove schedule
            SSSchedule.sharedInstance().schedules[date.keyFromDate] = nil
        }
    }
}