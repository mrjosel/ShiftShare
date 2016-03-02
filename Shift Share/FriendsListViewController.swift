//
//  FriendsListViewController.swift
//  Shift Share
//
//  Created by Brian Josel on 3/2/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import UIKit
import Firebase

class FriendsListViewController: KeyboardPresentViewController {

    //user
    var user : SSUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "Friends"
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
