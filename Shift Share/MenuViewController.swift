//
//  MenuViewController.swift
//  Shift Share
//
//  Created by Brian Josel on 2/29/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import UIKit


//enum to propulate cells in tableView
enum MenuCellTitle : Int {
    
    //CELLS POPULATE IN THIS ORDER
    case User = 0, Friends, Share, Retrieve, Logout
    
    //title names for cells
    static let titleNames = [
        User: "UserName",
        Friends: "Friends",
        Retrieve: "Retrieve Backup",
        Logout: "Logout"
    ]
    
    var description : String {
        get {
            //cast imageName to name and return, failed cast returns "DayViewImage"
            guard let name = MenuCellTitle.titleNames[self] else {
                return "Missing Menu Title"
            }
            return name
        }
    }
}

//shows menu, allows users to logout, and switch between friends' schedules
class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //TODO: MAKE INTO SLIDE OUT MENU FOR PRODUCTION

    //outlets
    @IBOutlet weak var menuTable: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //setup UIViews
        self.menuTable.scrollEnabled = false
        
        // Do any additional setup after loading the view.
    }
    
    //number of rows
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuCellTitle.titleNames.count
    }
    
    //how to populate cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //create cell
        guard let cell = tableView.dequeueReusableCellWithIdentifier("MenuTableCell") as? SSTableViewCell else {
            print("no cell made")
            return UITableViewCell()
        }
        
        //create title
        if let title = MenuCellTitle(rawValue: indexPath.row)?.description {
            cell.textLabel?.text = title
            cell.imageView?.image = UIImage(named: title)
            cell.detailTextLabel?.text = nil
        }
        
        
        self.tableViewHeight.constant = CGFloat(Int(cell.frame.height) * MenuCellTitle.titleNames.count)
        return cell
    }
    
    //present next view depending on which cell is selected
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //get title of cell, transtion to next view
        let rawVal = indexPath.row
        
        //get enum for selected cell
        guard let cellTitle = MenuCellTitle(rawValue: rawVal) else {
            self.makeAlert(self, title: "Critical Error : UI", error: nil)
            return
        }
        
        switch cellTitle {
        case MenuCellTitle.User :
            print("\(MenuCellTitle.User.description) was Selected")
        case MenuCellTitle.Friends :
            print("\(MenuCellTitle.Friends.description) was Selected")
        case MenuCellTitle.Share :
            print("\(MenuCellTitle.Share.description) was Selected")
        case MenuCellTitle.Retrieve :
            print("\(MenuCellTitle.Retrieve.description) was Selected")
        case MenuCellTitle.Logout :
            print("\(MenuCellTitle.Logout.description) was Selected")
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        
    }

    //dismiss VC
    func dismissVC() {
        self.dismissViewControllerAnimated(true, completion: nil)
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
