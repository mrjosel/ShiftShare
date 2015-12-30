//
//  SSNote.swift
//  Shift Share
//
//  Created by Brian Josel on 11/19/15.
//  Copyright © 2015 Brian Josel. All rights reserved.
//

import Foundation
import UIKit

//notes to populate SSDayViews
class SSNote : SSTBCellData, CustomStringConvertible {
    
    //title, body, image for protocol conformance
    @objc var title : String?
    @objc var body : String?
    @objc var image : UIImage? = UIImage(named: "Note")  //Note image is always of "Note"
    
    //description for CustomStringConvertible conformance
    var description : String {
        get {
            //if no title, return String of self
            guard let title = self.title else {
                return "\(self)"
            }
            
            //title exists, check for body
            guard let body = self.body else {
                return title
            }
            
            //title and body both exist
            return "\(title) (body: \(body))"
        }
    }
    
    //empty initializer
    init() {
        self.title = nil
        self.body = nil
    }
    
    //init with title, optional body
    init(title: String?, body: String?) {
        
        //set properties to params
        self.title = title
        self.body = body
        
    }
}