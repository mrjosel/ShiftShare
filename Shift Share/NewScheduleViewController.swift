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
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var newScheduleTable: UITableView!
    
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

    }
    
    //number of rows in the table, populate with new schedule data cells
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let schedule = schedule {
            print("count is \(SSSchedule.newScheduleData(schedule).count)")
            return SSSchedule.newScheduleData(schedule).count
        }
        print("count is \(SSSchedule.newScheduleData(nil).count)")
        return SSSchedule.newScheduleData(nil).count
    }
    
    
    //creates cells for the table
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //create cell
        guard let cell = tableView.dequeueReusableCellWithIdentifier("SSTableViewCell") as? SSTableViewCell,
            date = self.date else {
                print("no cell made")
                return UITableViewCell()
        }
        
        //set date in cell (for bookkeeping, may be removed later)
        cell.date = date
        
        //get data to populate cells
        var tableData : [SSTBCellData] = []
        
        if let schedule = schedule {
            
            //get tableData
            tableData = schedule.tableData
            
        } else {
            
            //create table data based on edit mode or not
            tableData = SSSchedule.newScheduleData(nil)
            
        }
        
        //get cellData from tableData
        let cellData = tableData[indexPath.row]
        
        //set cell properties
        cell.imageView?.image = cellData.image
        cell.textLabel?.text = cellData.title
        cell.detailTextLabel?.text = cellData.body
        
        return cell
        
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
        
        //dismiss viewController
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
