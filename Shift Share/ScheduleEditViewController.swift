//
//  ScheduleEditViewController.swift
//  Shift Share
//
//  Created by Brian Josel on 12/10/15.
//  Copyright © 2015 Brian Josel. All rights reserved.
//

import UIKit
import JTCalendar
import Parse

//vc for creating/editing schedules
class ScheduleEditViewController: UIViewController {

    
    //schedule that will be created
    var schedule : SSSchedule?
    
    //outlets
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        print(schedule)
        
        //setup views
        self.cancelButton.setTitle("Cancel", forState: UIControlState.Normal)
        self.doneButton.setTitle("Done", forState: UIControlState.Normal)
        self.cancelButton.addTarget(self, action: "cancelButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        self.doneButton.addTarget(self, action: "doneButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
//        self.addTarget(self.hostViewController, action: "editCancelTodayButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //user presses cancel button
    func cancelButtonPressed(sender: UIButton) {
        
        //dismiss viewController
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //user presses done button, commit all changes to schedule
    func doneButtonPressed(sender: UIButton) {
        
        //TODO : NEED TO IMPLEMENT
        print("doneButtonPressed")
        
        //dismiss viewController
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
