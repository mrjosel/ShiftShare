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
class SSNote : NSObject, SSTBCellData{//, CustomStringConvertible {
    
    //title, body, image for protocol conformance
    var title : String? {
        didSet {
            //alert the delegate
            self.schedule?.manager?.didChangeNoteOrContents(self.schedule!)
        }
    }
    var body : String? {
        didSet {
            //alert the delegate
            self.schedule?.manager?.didChangeNoteOrContents(self.schedule!)
        }
    }
    var image : UIImage? = UIImage(named: "Note")  //Note image is always of "Note"
    
    //schedule assiciated with note
    var schedule : SSSchedule?
    
    //description for CustomStringConvertible conformance
    override var description : String {
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
    override init() {
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