//
//  ScheduleItemViewController.swift
//  Shift Share
//
//  Created by Brian Josel on 12/16/15.
//  Copyright © 2015 Brian Josel. All rights reserved.
//

import UIKit
import JTCalendar
import CoreData

//presents shift or note in detail
class ScheduleItemViewController: KeyboardPresentViewController, UITextViewDelegate, UITextFieldDelegate {
    
    //outlets
    @IBOutlet weak var dataImageView: UIImageView!
    @IBOutlet weak var dataBody: UITextView!
    @IBOutlet weak var dataTitle: UITextField!
    @IBOutlet weak var leftTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var menuBar: JTCalendarMenuView!
    @IBOutlet weak var dateLabel: UILabel!
    
    //delegate
    var delegate : ScheduleEditViewControllerDelegate?    //since VC can edit schedules
    
    //data from cell, sent from prior VC
    var scheduleItem : SSScheduleItem?
    var schedule : SSSchedule!
    var configForShift : Bool = false //default value
    
    //remaining vars
    var previousRect = CGRectZero
    var newLineCount = 0
    var numLines : Int?
    var maxLines : Int!
    var touchGesture : UITapGestureRecognizer?
    
    
    //default shiftType
    var scratchShiftType : SSShiftType?
    
    override func viewWillAppear(animated: Bool) {
        
        //hide navBar
        self.navigationController?.navigationBarHidden = true

        //subscribe to keyboard notifications to allow view resizing
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //setup views for all common/static behaviors
        let trailingConstraint = self.view.frame.width / 16.0
        self.leftTrailingConstraint.constant = trailingConstraint
        self.rightTrailingConstraint.constant = trailingConstraint
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.navigationBar.hidden = false
        self.dateLabel.text = self.schedule.date!.readableDate
        self.dataTitle.borderStyle = .None
        self.dataTitle.textAlignment = NSTextAlignment.Center
        self.touchGesture = UITapGestureRecognizer(target: self, action: #selector(self.imageViewTapped(_:)))
        self.dataImageView.addGestureRecognizer(self.touchGesture!)
        self.dataBody.font = UIFont(name: "Helvetica", size: 14.0)
        self.dataBody.delegate = self
        self.dataTitle.delegate = self
        self.saveButton.setTitle("Save", forState: UIControlState.Normal)
        self.cancelButton.setTitle("Cancel", forState: UIControlState.Normal)
        self.menuBar.bringSubviewToFront(self.cancelButton)
        self.menuBar.bringSubviewToFront(self.saveButton)
        self.deleteButton.title = "Delete"

        
        //get default shift, setup saveButton behavior
        if self.configForShift {
            
            //check if shift was sent
            if let scheduleItem = self.scheduleItem as? SSShift {
                //item sent was shift, don't allow saving until user taps image
                self.scratchShiftType = scheduleItem.type
                self.saveButton.enabled = false
            } else {
                //no item sent, configure for new shift
                self.scratchShiftType = SSShiftType.DAY
                self.saveButton.enabled = true
            }
        } else {
            //data is a note, don't allow saving unitl user edits the textField or textView
            self.saveButton.enabled = false
        }

        
        //configure UI elements for all dynamic behaviors (e.g. - if shift, or note changes)
        self.configUIForData()

        //get numLines and maxLines
        self.maxLines = Int((self.dataBody.frame.height - self.dataBody.textContainerInset.top - self.dataBody.textContainerInset.bottom) / self.dataBody.font!.lineHeight)
        self.numLines = Int((self.dataBody.contentSize.height - self.dataBody.textContainerInset.top - self.dataBody.textContainerInset.bottom) / self.dataBody.font!.lineHeight)
        
    }
    
    //cycle shift when image tapped, ignore for notes
    func imageViewTapped(sender: UITapGestureRecognizer) {
        
        //enable save button
        self.saveButton.enabled = true
        
        //check if data is shift or not
        if self.configForShift {
            
            //cycle shift
            self.scratchShiftType!.cycleShift()
            
            //config UI
            dispatch_async(dispatch_get_main_queue(), {
                self.configUIForData()
            })
        }
    }
    
    //check if data is shift, if not shift, allow editing of text body until body is full, otherwise disallow
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        //get text and new text
        let content = textView.text as NSString
        let newText = content.stringByReplacingCharactersInRange(range, withString: text)
        
        //check if data is shift
        if !self.configForShift {
            
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
        
        //enable save button
        self.saveButton.enabled = true
        
        //update number of lines
        self.numLines = Int((self.dataBody.contentSize.height - self.dataBody.textContainerInset.top - self.dataBody.textContainerInset.bottom) / self.dataBody.font!.lineHeight)
        
        //check for word wrap event if numLines exceeds maxLines, if wordwrap occured remove chars until maxLines not exceeded
        while self.numLines > self.maxLines {
            textView.text = textView.text.substringToIndex(textView.text.endIndex.predecessor())
            self.numLines = Int((self.dataBody.contentSize.height - self.dataBody.textContainerInset.top - self.dataBody.textContainerInset.bottom) / self.dataBody.font!.lineHeight)
        }
        
    }
    
    //cannot save notes unless textView or textField has been edited
    func textViewDidBeginEditing(textView: UITextView) {
        
        //make sure its a note
        if !self.configForShift {
            self.saveButton.enabled = true
            textView.text = self.scheduleItem?.body
        }
    }
    
    //cannot save notes unless textView or textField has been edited
    func textFieldDidBeginEditing(textField: UITextField) {
        
        //make sure its a note
        if !self.configForShift {
            self.saveButton.enabled = true
            textField.text = self.scheduleItem?.title
        }
    }
    
    //manages text editing for dataTitle
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if !self.configForShift {
            //TODO: HANDLE EDITING OF NOTE LABEL
            
            //enable save button
            self.saveButton.enabled = true
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
        if !self.configForShift {
            
            //image is always Note for note
            self.dataImageView.image = UIImage(named: "Note")

            if let title = self.scheduleItem?.title {
                self.dataTitle.text = title
            } else {
                self.dataTitle.text = "Your Note Title"
            }
            if let body = self.scheduleItem?.body {
                self.dataBody.text = body
            } else {
                self.dataBody.text = "Your Note Body"
            }
            
        } else {
            self.dataImageView.image = UIImage(named: SSShiftType.shiftNames[self.scratchShiftType!]!)
            self.dataBody.text = SSShiftType.shiftTimes[self.scratchShiftType!]
            self.dataTitle.text = SSShiftType.shiftNames[self.scratchShiftType!]
        }
        
        //Outlet configuration depending if data is a shift or a note
        self.dataBody.textAlignment = self.configForShift ? NSTextAlignment.Center : NSTextAlignment.Left
        self.dataBody.userInteractionEnabled = !self.configForShift
        self.dataTitle.userInteractionEnabled = !self.configForShift
        self.dataTitle.selected = !self.configForShift
        self.dataImageView.userInteractionEnabled = self.configForShift
        
        //delete button only on if scheduleItem is set (implying item is from a store and not a new item)
        self.deleteButton.enabled = {
            return self.scheduleItem != nil
        }()
    }
    
    //return to calendar without changes
    @IBAction func cancelButtonPressed(sender: UIButton) {
        //return back to calendar
//        let item = self.configForShift ? self.scheduleItem as! SSShift : self.scheduleItem as! SSNote
//        CoreDataStackManager.sharedInstance().managedObjectContext.deleteObject(item)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //return to calendar without changes
    @IBAction func saveButtonPressed(sender: UIButton) {
        
        //if no schedule item set, create it
        if self.scheduleItem == nil {
            //newItem
            var newItem : SSScheduleItem
            
            //create new item depending on shift or not
            if self.configForShift {
                //create a shift from scratch type
                newItem = SSShift(type: self.scratchShiftType, context: CoreDataStackManager.sharedInstance().managedObjectContext)
            } else {
                //create new note from texts
                newItem = SSNote(title: self.dataTitle.text, body: self.dataBody.text, context: CoreDataStackManager.sharedInstance().managedObjectContext)
            }
            
            //set schedule
            newItem.schedule = self.schedule
            
        } else {
            //item was sent and edited, commit changes
            if self.configForShift {
                //set scratch shift to item's shift
                let item = self.scheduleItem as! SSShift
                item.type = self.scratchShiftType
            } else {
                //set note fields from texts, unless empty, then remove note
                let item = self.scheduleItem as! SSNote
                
                //if noth fields are empty, remove
                if self.dataBody.text == "" && self.dataTitle.text == "" {
                    //delete note
                    CoreDataStackManager.sharedInstance().managedObjectContext.deleteObject(item)
                }

                //set texts
                item.body = self.dataBody.text
                item.title = self.dataTitle.text
            }
        }

        //save context
        CoreDataStackManager.sharedInstance().saveContext()

        //return back to calendar
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //delete shift or note
    @IBAction func deleteButtonPressed(sender: UIBarButtonItem) {
        
    //determine shit or not
        if self.configForShift {
            let shift = self.scheduleItem as! SSShift
            CoreDataStackManager.sharedInstance().managedObjectContext.deleteObject(shift)
        } else {
            let note = self.scheduleItem as! SSNote
            CoreDataStackManager.sharedInstance().managedObjectContext.deleteObject(note)
        }
        
        //return back to calendar
        self.navigationController?.popViewControllerAnimated(true)
    }

    //make all values nil
    override func viewWillDisappear(animated: Bool) {
        self.scheduleItem = nil
        self.numLines = nil
        
        //unsubscribe to keyboard notifications to allow view resizing
        self.unsubscribeToKeyboardNotifications()
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
