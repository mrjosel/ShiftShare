//
//  FriendsListViewController.swift
//  Shift Share
//
//  Created by Brian Josel on 3/2/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import UIKit
import Firebase

class FriendsListViewController: KeyboardPresentViewController, UITableViewDelegate, UITableViewDataSource {

    //outlets
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var menuBar: UIView!
    @IBOutlet weak var friendsTable: UITableView!
    
    //user
    var user : SSUser!
    var friends : [SSUser]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //setup views
        self.menuButton.setTitle("Menu", forState: .Normal)
        self.menuButton.addTarget(self, action: #selector(self.menuButtonPressed), forControlEvents: .TouchUpInside)
        self.menuBar.bringSubviewToFront(self.menuButton)
        self.titleLabel.text = "Friends"
        self.rightButton.hidden = true
        
        //delegates
        self.friendsTable.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "Friends"
    }
    
    //number of rows
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //TODO: Perform HTTP GET assemble friend objects, populate accordingly
        return 1 //will change
    }
    
    //construct cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("friendCell")!
        
        if let friends = self.friends {
            cell.textLabel?.text = friends[indexPath.row].wholeName
        }
        
        return cell
    }
    
    //return to menu
    func menuButtonPressed() {
        self.navigationController?.popViewControllerAnimated(true)
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
