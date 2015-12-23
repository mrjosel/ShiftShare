//
//  ScheduleDetailViewController.swift
//  Shift Share
//
//  Created by Brian Josel on 12/16/15.
//  Copyright © 2015 Brian Josel. All rights reserved.
//

import UIKit

class ScheduleDetailViewController: UIViewController {
    
    //outlets
    @IBOutlet weak var noteView: UIView!    //view with all components for when note is selected
    @IBOutlet weak var shiftView: UIView!   //view with all components for when shift is selected
    @IBOutlet weak var noteBody: UITextView!
    
    //data from cell selected in CalendarVC
    var userSelectedData : SSTBCellData?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //ensure that userSelectedData has made it to VC
        guard let data = self.userSelectedData else {
            
            //no data found, do not configure, return
            return
        }
        
        //use dataIsShift as Bool for configuation.  If false, implies that data is of SSNote type
        let dataIsShift = (data is SSShift)
        
        //setup views
        self.navigationController?.navigationBar.hidden = false
        self.navigationController?.topViewController?.title = (dataIsShift) ? "Shift" : "Note"
        self.shiftView.hidden = !dataIsShift
        self.noteView.hidden = dataIsShift
        self.noteBody.text = data.body
        self.noteBody.textAlignment = NSTextAlignment.Left

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

}
