//
//  TBDataEditViewController.swift
//  Shift Share
//
//  Created by Brian Josel on 12/16/15.
//  Copyright © 2015 Brian Josel. All rights reserved.
//

import UIKit
import JTCalendar
import CoreData

//presents shift or note in detail
class TBDataEditViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
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
    
    //data from cell selected in CalendarVC
    var scheduleItem : SSScheduleItem!
    var schedule : SSSchedule?
    var dataIsShift : Bool = false          //default value
    var previousRect = CGRectZero
    var newLineCount = 0
    var numLines : Int?
    var maxLines : Int!
    var touchGesture : UITapGestureRecognizer?
    var selectedIndexPath : NSIndexPath!
    
    //selected date
    var date : NSDate!

    
    //default shiftType
    var scratchShiftType : SSShiftType?
    
    //notes fetch results controller
    lazy var notesFetchResultsController : NSFetchedResultsController = {
        
        //create fetch
        let fetchRequest = NSFetchRequest(entityName: "SSNote")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "schedule == %@", self.schedule!)
        
        //create and return controller
        let fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStackManager.sharedInstance().managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchResultsController
        
    }()
    
    //shift fetch results controller
    lazy var shiftFetchResultsController : NSFetchedResultsController = {
        
        //create fetch
        let fetchRequest = NSFetchRequest(entityName: "SSShift")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "schedule == %@", self.schedule!)
        
        //create and return controller
        let fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStackManager.sharedInstance().managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchResultsController
    }()

    
    override func viewWillAppear(animated: Bool) {
        
        //hide navBar
        self.navigationController?.navigationBarHidden = true

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //if schedule exists for date, use it, otherwise use schedule set in other VC, if not set, create empty schedule for user
        if self.schedule == nil {

            //schedule not present for date, does not exist, creating new schedule
            self.schedule = SSSchedule(forDate: self.date, forUser: "Brian", context: CoreDataStackManager.sharedInstance().managedObjectContext)
        }
        
        //get item from store
        self.getItemFromStore(atIndexPath: self.selectedIndexPath)
        print(self.scheduleItem)
        print(self.dataIsShift)
        
        //get default shift, setup saveButton behavior
        if self.dataIsShift {
            if let type = (self.scheduleItem as! SSShift).type {
                //type is set implying its an existing schedule, don't allow saving until user taps image
                self.scratchShiftType = type
                self.saveButton.enabled = false
            } else {
                //type is not set so its a new schedule, allow saving
                self.scratchShiftType = SSShiftType.DAY
                self.saveButton.enabled = true
            }
        } else {
            //data is a note, don't allow saving unitl user edits the textField or textView
            self.saveButton.enabled = false
        }
        
        //setup views for all common/static behaviors
        let trailingConstraint = self.view.frame.width / 16.0
        self.leftTrailingConstraint.constant = trailingConstraint
        self.rightTrailingConstraint.constant = trailingConstraint
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.navigationBar.hidden = false
        self.dateLabel.text = date.readableDate
        self.dataTitle.borderStyle = .None
        self.dataTitle.textAlignment = NSTextAlignment.Center
        self.touchGesture = UITapGestureRecognizer(target: self, action: "imageViewTapped:")
        self.dataImageView.addGestureRecognizer(self.touchGesture!)
        self.dataBody.font = UIFont(name: "Helvetica", size: 14.0)
        self.dataBody.delegate = self
        self.dataTitle.delegate = self
        self.saveButton.setTitle("Save", forState: UIControlState.Normal)
        self.cancelButton.setTitle("Cancel", forState: UIControlState.Normal)
        self.menuBar.bringSubviewToFront(self.cancelButton)
        self.menuBar.bringSubviewToFront(self.saveButton)
        self.deleteButton.title = "Delete"

        
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
        if !self.dataIsShift {
            //do nothing
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
        if !self.dataIsShift {
            self.saveButton.enabled = true
        }
    }
    
    //cannot save notes unless textView or textField has been edited
    func textFieldDidBeginEditing(textField: UITextField) {
        
        //make sure its a note
        if !self.dataIsShift {
            self.saveButton.enabled = true
        }
    }
    
    //manages text editing for dataTitle
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if !self.dataIsShift {
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
        if !self.dataIsShift {
            if let imageName = self.scheduleItem.imageName {
                self.dataImageView.image = UIImage(named: imageName)
            } else {
                self.dataImageView.image = nil
            }
            self.dataBody.text = self.scheduleItem.body
            self.dataTitle.text = self.scheduleItem.title
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
    
    //return to calendar without changes
    @IBAction func cancelButtonPressed(sender: UIButton) {
        //return back to calendar
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //return to calendar without changes
    @IBAction func saveButtonPressed(sender: UIButton) {
        
        //if schedule not set, set it
        if self.scheduleItem.schedule == nil {
            self.scheduleItem.schedule = self.schedule
        }

        //make changes to shift/note
        if self.dataIsShift {
            let data = self.scheduleItem as! SSShift
            data.type = self.scratchShiftType
        } else {
            var data = self.scheduleItem as? SSNote
            data!.body = self.dataBody.text
            data!.title = self.dataTitle.text
            
            //if body and title are "", delete
            if self.dataBody.text == "" && self.dataTitle.text == "" {
                //delete note
                data = nil
            }
        }
        
        //save context
        do {
            try CoreDataStackManager.sharedInstance().managedObjectContext.save()
        } catch {
            //TODO: HANDLE ERROR
        }
        
        //return back to calendar
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //delete shift or note
    @IBAction func deleteButtonPressed(sender: UIBarButtonItem) {
        
        //determine shit or not
        if self.dataIsShift {
            //data is shift, set to nil
            self.schedule?.shift = nil
        } else {
            //data is note, remove from notes index, forst case data to note object
            let note = self.scheduleItem as! SSNote
            
            //get index and remove
            if let index = self.schedule?.notes?.indexOf({$0.body == note.body && $0.title == note.title}) {
                self.schedule?.notes?.removeAtIndex(index)
            }
        }
        
        //return back to calendar
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //method to get item to be used in schedule editing
    func getItemFromStore(atIndexPath indexPath: NSIndexPath) {
        
        //check section
        if indexPath.section == 0 {
            //item is a shift
            self.dataIsShift = true
            if let shifts = self.shiftFetchResultsController.fetchedObjects where shifts.count != 0 {
                //shift exists in store
                self.scheduleItem = shifts[indexPath.row] as! SSShift
            } else {
                //no shift in store, make new shift to edit
                scheduleItem = SSShift(type: SSShiftType.DAY, context: CoreDataStackManager.sharedInstance().managedObjectContext)
            }
        } else {
            //item is a note
            self.dataIsShift = false
            if let notes = self.notesFetchResultsController.fetchedObjects where notes.count != 0 {
                //note exists in store
                self.scheduleItem = notes[indexPath.row] as! SSNote
            } else {
                //no note in store, make new note
                self.scheduleItem = SSNote(title: "New Note", body: "Your note content", context: CoreDataStackManager.sharedInstance().managedObjectContext)
            }
        }
    }
    
    //make all values nil
    override func viewWillDisappear(animated: Bool) {
        self.scheduleItem = nil
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
