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
class SSNote : CustomStringConvertible {
    
    //title and body
    var title : String
    var body : String?
    
    //description for CustomStringConvertible conformance
    var description : String {
        get {
            guard let body = self.body else {
                return title
            }
            return "\(title) (body: \(body))"
        }
    }
    
    //empty initializer
    init() {
        self.title = "no title"
    }
    
    //init with title, optional body
    init(title: String, body: String?) {
        
        //set properties to params
        self.title = title
        self.body = body
        
    }
}