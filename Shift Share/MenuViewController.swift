//
//  MenuViewController.swift
//  Shift Share
//
//  Created by Brian Josel on 2/29/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import UIKit

//shows menu, allows users to logout, and switch between friends' schedules
class MenuViewController: UIViewController {
    
    //TODO: MAKE INTO SLIDE OUT MENU FOR PRODUCTION

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
