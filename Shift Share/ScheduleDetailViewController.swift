//
//  ScheduleDetailViewController.swift
//  Shift Share
//
//  Created by Brian Josel on 12/16/15.
//  Copyright © 2015 Brian Josel. All rights reserved.
//

import UIKit

//presents shift or note in detail
class ScheduleDetailViewController: UIViewController, UITextViewDelegate {
    //TODO: PRESENT NOTES NICELY
    //TODO: PRESENT SHIFT SOMEHOW
    //outlets
    @IBOutlet weak var noteView: UIView!    //view with all components for when note is selected
    @IBOutlet weak var shiftView: UIView!   //view with all components for when shift is selected
    @IBOutlet weak var shiftImageView: UIImageView!
    @IBOutlet weak var noteBody: UITextView!
    @IBOutlet weak var shiftTime: UITextView!
    @IBOutlet weak var shiftName: UILabel!
    
    //data from cell selected in CalendarVC
    var userSelectedData : SSTBCellData?
    var dataIsShift : Bool = false  //set to false as default
    
    //selected date
    var date : NSDate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //ensure that userSelectedData has made it to VC
        guard let data = self.userSelectedData else {
            
            //no data found, do not configure, return
            return
        }
        
        print(self.date)
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        //use dataIsShift as Bool for configuation.  If false, implies that data is of SSNote type
        self.dataIsShift = (data is SSShift)
        
        //setup views
        self.navigationController?.navigationBar.hidden = false
        self.navigationController?.topViewController?.title = self.date.readableDate
        self.shiftView.hidden = !self.dataIsShift
        self.shiftImageView.image = data.image
        self.shiftTime.text = data.body
        self.shiftTime.textAlignment = NSTextAlignment.Center
        self.shiftTime.delegate = self
        self.shiftName.text = data.title
        self.shiftName.textAlignment = NSTextAlignment.Center
        self.noteView.hidden = self.dataIsShift
        self.noteBody.text = data.body
        self.noteBody.textAlignment = NSTextAlignment.Left
        self.noteBody.delegate = self

    }
    
    //when field is selected, allow for editing of notes, and selection of shifts
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        print("did select textView")
        return !self.dataIsShift
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
