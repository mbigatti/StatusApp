//
//  StatusEntity.swift
//  StatusApp
//
//  Created by Massimiliano Bigatti on 24/06/14.
//  Copyright (c) 2014 Massimiliano Bigatti. All rights reserved.
//

import Foundation

/**
Entry entity. Each entry is defined by:
- a title
- free text note
- a color
- last updated date
 */
class StatusEntity : NSObject, NSCoding
{
    
    /// entry title
    var title : String {
        didSet {
            lastUpdateDate = NSDate()
        }
    }
    
    /// entry notes
    var notes : String {
        didSet {
            lastUpdateDate = NSDate()
        }
    }

    /// entry color
    var color : StatusEntityColor {
        didSet {
            lastUpdateDate = NSDate()
        }
    }
    
    /// readonly last updated timestamp
    private(set) var lastUpdateDate : NSDate
    
    /**
     Inits an entry (required by `NSKeyedUnarchiver`)
    :param: coder an `NSCoder` object
    */
    required init(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObjectForKey("title") as String
        notes = aDecoder.decodeObjectForKey("notes") as String
        lastUpdateDate = aDecoder.decodeObjectForKey("lastUpdateDate") as NSDate
        color = StatusEntityColor.fromRaw(aDecoder.decodeObjectForKey("color") as NSInteger)!
    }
    
    init(title: String, notes: String, color: StatusEntityColor) {
        self.title = title
        self.notes = notes
        self.lastUpdateDate = NSDate.date()
        self.color = color
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(title, forKey: "title")
        aCoder.encodeObject(notes, forKey: "notes")
        aCoder.encodeObject(lastUpdateDate, forKey: "lastUpdateDate")
        aCoder.encodeObject(color.toRaw(), forKey: "color")
    }
}