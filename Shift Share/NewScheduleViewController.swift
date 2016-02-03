//
//  NewScheduleViewController.swift
//  Shift Share
//
//  Created by Brian Josel on 12/10/15.
//  Copyright © 2015 Brian Josel. All rights reserved.
//

import UIKit
import JTCalendar
import Parse

//vc for creating/editing schedules
class NewScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    //schedule that will be created for that date
    var schedule : SSSchedule?
    var date : NSDate!
    
    //outlets
    @IBOutlet weak var menuBar: JTCalendarMenuView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var newScheduleTable: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func viewWillAppear(animated: Bool) {

        //hide navBar
        self.navigationController?.navigationBar.hidden = true
        
        //generate new schedule data
        SSSchedule.newScheduleData(self.schedule)
        
        //reload table
        self.newScheduleTable.reloadData()
        
        print(self.schedule?.shift?.title)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //delegate and datasource for tableView
        self.newScheduleTable.delegate = self
        self.newScheduleTable.dataSource = self
        
        //setup views
        self.cancelButton.setTitle("Cancel", forState: UIControlState.Normal)
        self.doneButton.setTitle("Done", forState: UIControlState.Normal)
        self.cancelButton.addTarget(self, action: "cancelButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        self.doneButton.addTarget(self, action: "doneButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        self.menuBar.bringSubviewToFront(self.cancelButton)
        self.menuBar.bringSubviewToFront(self.doneButton)
        self.dateLabel.text = self.date.readableDate

    }
    
    //number of rows in the table, populate with new schedule data cells
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //if no schedule, return
        guard let schedule = self.schedule else {
            self.navigationController?.popToRootViewControllerAnimated(true)
            return 0
        }
        
        return schedule.tableData.count
    }
    
    //creates cells for the table
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //create cell
        guard let cell = tableView.dequeueReusableCellWithIdentifier("SSTableViewCell") as? SSTableViewCell,
            schedule = self.schedule,
            date = self.date else {
                print("no cell made")
                self.navigationController?.popToRootViewControllerAnimated(true)
                return UITableViewCell()
        }
        
        //set date in cell (for bookkeeping, may be removed later)
        cell.date = date

        //get cellData from tableData
        let cellData = schedule.tableData[indexPath.row]
        
        //set cell properties
        cell.imageView?.image = cellData.image
        cell.textLabel?.text = cellData.title
        cell.detailTextLabel?.text = cellData.body
        
        //hide detail label if its newNote (end of tableData)
        cell.detailTextLabel?.hidden = (indexPath.row == schedule.tableData.count - 1) ? true : false
        
        return cell
        
    }
    
    //clicking cells launches VC to create shift
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //get data for detailVC
        guard let cellData = self.schedule?.tableData[indexPath.row] else {
            //no schedule, return
            self.navigationController?.popToRootViewControllerAnimated(true)
            return
        }

        //perform segue to editVC
        self.performSegueWithIdentifier("editVCSegueFromNew", sender: cellData)
        
    }
    
    //segue to scheduleEditVC
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "editVCSegueFromNew" {
            
            //create VC for show presentation
            let scheduleEditVC : ScheduleEditViewController = segue.destinationViewController as! ScheduleEditViewController
            
            //set VC's date to selectedDate, and cast sender as SSTBCellData
            scheduleEditVC.userSelectedData = sender as? SSTBCellData
            scheduleEditVC.date = self.date
            scheduleEditVC.schedule = self.schedule
        }
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
        
        //clear out schedule
        self.schedule = nil
        
        //dismiss viewController
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    //user presses done button, commit all changes to schedule
    func doneButtonPressed(sender: UIButton) {
        
        //remove new schedule date
        if self.schedule?.shift?.schedule == nil {
            self.schedule?.shift = nil
        }
        
        //remove new note data
        if let notes = self.schedule?.notes {
            print("we have notes")
            if let index = notes.indexOf({
            if $0.schedule == nil {
                print("newNoteFound")
                return true
            } else {
                print("didn't find that shit")
                return false
                }
            }) {
                print("removing new note")
                self.schedule!.notes?.removeAtIndex(index)
            } else {
                print("newnote not found")
                //TODO:     FIX NEW NOTE NOT FOUND BUG
                //          FIX BUG WHERE NOTES DON'T POPULATE RIGHT
            }

        }
        
        //add schedule to array
        SSSchedule.sharedInstance().schedules[self.date.keyFromDate] = self.schedule
        
        //dismiss viewController
        self.navigationController?.popToRootViewControllerAnimated(true)
    }

}
