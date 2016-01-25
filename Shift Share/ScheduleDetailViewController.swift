//
//  ScheduleDetailViewController.swift
//  Shift Share
//
//  Created by Brian Josel on 12/16/15.
//  Copyright © 2015 Brian Josel. All rights reserved.
//

import UIKit

//presents shift or note in detail
class ScheduleDetailViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    //TODO: CREATE SAVE BUTTON ON RIGHT THAT SAVES NOTE AND SEGUES BACK TO CALENDARVC
    //TODO: LIMIT CHARACTERS IN DATATITLE TEXTFIELD
    
    //outlets
    @IBOutlet weak var dataImageView: UIImageView!
    @IBOutlet weak var dataBody: UITextView!
    @IBOutlet weak var dataTitle: UITextField!
    @IBOutlet weak var leftTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightTrailingConstraint: NSLayoutConstraint!
    
    //data from cell selected in CalendarVC
    var userSelectedData : SSTBCellData!    //set in calendarViewController
    var schedule : SSSchedule?
    var dataIsShift : Bool = false          //default value
    var previousRect = CGRectZero
    var newLineCount = 0
    var numLines : Int?
    var maxLines : Int!
    var touchGesture : UITapGestureRecognizer?
    
    //selected date
    var date : NSDate!                      //set in calendarViewController
    
    //default shiftType
    var scratchShiftType : SSShiftType?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //get schedule for use in other methods
        if let schedule = SSSchedule.sharedInstance().schedules[date.keyFromDate] {
            self.schedule = schedule
        }
        
        //determine if data is shift or note
        self.dataIsShift = self.userSelectedData is SSShift
        
        //get default shift
        if self.dataIsShift {
            self.scratchShiftType = (self.userSelectedData as! SSShift).type
        }
        
        //setup views for all common/static behaviors
        let trailingConstraint = self.view.frame.width / 16.0
        self.leftTrailingConstraint.constant = trailingConstraint
        self.rightTrailingConstraint.constant = trailingConstraint
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.navigationBar.hidden = false
        self.navigationController?.topViewController?.title = date.readableDate
        self.dataTitle.borderStyle = .None
        self.dataTitle.textAlignment = NSTextAlignment.Center
        self.touchGesture = UITapGestureRecognizer(target: self, action: "imageViewTapped:")
        self.dataImageView.addGestureRecognizer(self.touchGesture!)
        self.dataBody.font = UIFont(name: "Helvetica", size: 14.0)
        self.dataBody.delegate = self
        self.dataTitle.delegate = self
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "commitChanges")
        self.navigationItem.rightBarButtonItem?.enabled = false
        self.navigationItem.hidesBackButton = true
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelButtonPressed")
        self.navigationItem.leftBarButtonItem = cancelButton
        
        //configure UI elements for all dynamic behaviors (e.g. - if shift, or note changes)
        self.configUIForData()

        //get numLines and maxLines
        self.maxLines = Int((self.dataBody.frame.height - self.dataBody.textContainerInset.top - self.dataBody.textContainerInset.bottom) / self.dataBody.font!.lineHeight)
        self.numLines = Int((self.dataBody.contentSize.height - self.dataBody.textContainerInset.top - self.dataBody.textContainerInset.bottom) / self.dataBody.font!.lineHeight)
        
    }
    
    //cycle shift when image tapped, ignore for notes
    func imageViewTapped(sender: UITapGestureRecognizer) {
        
        //enable save button
        self.navigationItem.rightBarButtonItem?.enabled = true
        
        //check if data is shift or not
        if !self.dataIsShift {
            print("data is not shift")
        } else {
            
            //cycle shift
            self.scratchShiftType!.cycleShift()
            
            //config UI
            dispatch_async(dispatch_get_main_queue(), {
                self.configUIForData()
            })
        }
    }
    
    //TODO: DEBUG, REMOVE
    func textBody(lineCount: Int) -> String {
        var content = ""
        let usableCount = lineCount > self.maxLines ? self.maxLines : lineCount
        for var i = 0; i < usableCount - 1; i++ {
            content += "\(i).)\n"
        }
        content += "\(usableCount - 1).)"
        
        return content
    }
    
    //check if data is shift, if not shift, allow editing of text body until body is full, otherwise disallow
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        //get text and new text
        let content = textView.text as NSString
        let newText = content.stringByReplacingCharactersInRange(range, withString: text)
        
        //check if data is shift
        if !self.dataIsShift {
            
            //allow text input until last line is reached
            if self.numLines > self.maxLines {
                
                //last line was reached, textViewDidChange will check for wordwrap, return conditional allowing backspaces only
                return newText.characters.count < textView.text.characters.count
            }
            
            //allow change
            return true
            
        } else {
            //data is a shift, hide caret and do not allow editing
            textView.selectedTextRange = nil
            return false
        }
    }
    
    //update numLines everytime text changes, if word wrap occurs after maxLines reached, remove last char
    func textViewDidChange(textView: UITextView) {
        
        //update number of lines
        self.numLines = Int((self.dataBody.contentSize.height - self.dataBody.textContainerInset.top - self.dataBody.textContainerInset.bottom) / self.dataBody.font!.lineHeight)
        
        //check for word wrap event if numLines exceeds maxLines, if wordwrap occured remove chars until maxLines not exceeded
        while self.numLines > self.maxLines {
            textView.text = textView.text.substringToIndex(textView.text.endIndex.predecessor())
            self.numLines = Int((self.dataBody.contentSize.height - self.dataBody.textContainerInset.top - self.dataBody.textContainerInset.bottom) / self.dataBody.font!.lineHeight)
        }
        
    }
    
    //manages text editing for dataTitle
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if !self.dataIsShift {
            //TODO: HANDLE EDITING OF NOTE LABEL
            return true //for now
        } else {
            //data is a shift, hide caret and do not allow editing
            textField.selectedTextRange = nil
            return false
        }
    }
    
    //using shift type or note configure all UI elements
    func configUIForData() {
        
        //UI Outlet setup depending on whether shift or data
        if !self.dataIsShift {
            self.dataImageView.image = self.userSelectedData.image
            self.dataBody.text = self.userSelectedData.body
            self.dataTitle.text = self.userSelectedData.title
        } else {
            self.dataImageView.image = UIImage(named: SSShiftType.shiftNames[self.scratchShiftType!]!)
            self.dataBody.text = SSShiftType.shiftTimes[self.scratchShiftType!]
            self.dataTitle.text = SSShiftType.shiftNames[self.scratchShiftType!]
        }
        
        //Outlet configuration depending if data is a shift or a note
        self.dataBody.textAlignment = self.dataIsShift ? NSTextAlignment.Center : NSTextAlignment.Left
        self.dataBody.userInteractionEnabled = !self.dataIsShift
        self.dataTitle.userInteractionEnabled = !self.dataIsShift
        self.dataTitle.selected = !self.dataIsShift
        self.dataImageView.userInteractionEnabled = self.dataIsShift
    }
    
    //commit changes and return to calendar
    func commitChanges() {
        
        //make changes to shift/note
        if self.dataIsShift {
            let data = self.userSelectedData as! SSShift
            data.type = self.scratchShiftType
        } else {
            let data = self.userSelectedData as! SSNote
            data.body = self.dataBody.text
            data.title = self.dataTitle.text
        }
        
        //return back to calendar
        self.navigationController?.popViewControllerAnimated(true)
        
        
        //TODO: SAVE CONTEXT IN CORE DATA
        

    }
    
    //return to calendar without changes
    func cancelButtonPressed() {
        
        //return back to calendar
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    //make all values nil
    override func viewWillDisappear(animated: Bool) {
        self.userSelectedData = nil
        self.numLines = nil
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
