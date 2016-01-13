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

    //TODO: EDIT SHIFTS!!!
    
    //outlets
    @IBOutlet weak var dataImageView: UIImageView!
    @IBOutlet weak var dataBody: UITextView!
    @IBOutlet weak var dataTitle: UILabel!
    @IBOutlet weak var leftTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightTrailingConstraint: NSLayoutConstraint!
    
    //data from cell selected in CalendarVC
    var userSelectedData : SSTBCellData?
    var dataIsShift : Bool = false  //set to false as default
    var previousRect = CGRectZero
    var newLineCount = 0
    var numLines : Int?
    var maxLines : Int!
    var touchGesture : UITapGestureRecognizer?
    
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
        print(data)
        //determine if data is shift or not
        self.dataIsShift = (data is SSShift)
        
        //setup views
        let trailingConstraint = self.view.frame.width / 16.0
        self.leftTrailingConstraint.constant = trailingConstraint
        self.rightTrailingConstraint.constant = trailingConstraint
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.navigationBar.hidden = false
        self.navigationController?.topViewController?.title = self.date.readableDate
        self.dataImageView.image = data.image
        self.dataBody.text = data.body
        self.dataBody.textAlignment = self.dataIsShift ? NSTextAlignment.Center : NSTextAlignment.Left
        self.dataBody.font = UIFont(name: "Helvetica", size: 14.0)
        self.dataBody.delegate = self
        self.dataTitle.text = data.title
        self.dataTitle.textAlignment = NSTextAlignment.Center
        self.touchGesture = UITapGestureRecognizer(target: self, action: "imageViewTapped:")
        self.dataImageView.addGestureRecognizer(self.touchGesture!)
        self.dataImageView.userInteractionEnabled = true
        
        //get numLines and maxLines
        self.maxLines = Int((self.dataBody.frame.height - self.dataBody.textContainerInset.top - self.dataBody.textContainerInset.bottom) / self.dataBody.font!.lineHeight)
        self.numLines = Int((self.dataBody.contentSize.height - self.dataBody.textContainerInset.top - self.dataBody.textContainerInset.bottom) / self.dataBody.font!.lineHeight)
    }
    
    func imageViewTapped(sender: UITapGestureRecognizer) {
        if !self.dataIsShift {
            print("data is not shift")
        } else {
            if let schedule = SSSchedule.sharedInstance().schedules[self.date.keyFromDate], shift = schedule.shift {
                if let _ = shift.type {
                    shift.type!.cycleShift()
                    dispatch_async(dispatch_get_main_queue(), {
                        self.dataImageView.image = UIImage(named: shift.type!.description)
                        self.dataTitle.text = shift.type!.description
                    })
                }
            }
        }
    }
    
    //TODO: DEBUG, REMOVE
    func textBody(lineCount: Int) -> String {
        var content = ""
        let usableCount = lineCount > self.maxLines ? self.maxLines : lineCount
        print("lineCount is \(lineCount), maxLines is \(self.maxLines)")
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
            //data is shift, do not allow editing of body
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
