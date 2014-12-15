//
//  StatusEntity.swift
//  StatusApp
//
//  Created by Massimiliano Bigatti on 24/06/14.
//  Copyright (c) 2014 Massimiliano Bigatti. All rights reserved.
//

import Foundation
import CloudKit

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
    
    var uuid: String?
    
    /**
         Inits an entry (required by `NSKeyedUnarchiver`)
    
        :param: coder an `NSCoder` object
    */
    required init(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObjectForKey("title") as String
        notes = aDecoder.decodeObjectForKey("notes") as String
        lastUpdateDate = aDecoder.decodeObjectForKey("lastUpdateDate") as NSDate
        color = StatusEntityColor(rawValue: aDecoder.decodeObjectForKey("color") as NSInteger)!
        uuid = aDecoder.decodeObjectForKey("uuid") as? String
    }
    
    init(title: String, notes: String, color: StatusEntityColor) {
        self.title = title
        self.notes = notes
        self.lastUpdateDate = NSDate()
        self.color = color
    }
    
    init(record: CKRecord) {
        self.title = record.objectForKey("title") as String
        self.notes = record.objectForKey("notes") as String
        self.lastUpdateDate = record.objectForKey("lastUpdateDate") as NSDate
        self.color = StatusEntityColor(rawValue: record.objectForKey("colorInt") as Int)!
        self.uuid = record.recordID.recordName
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(title, forKey: "title")
        aCoder.encodeObject(notes, forKey: "notes")
        aCoder.encodeObject(lastUpdateDate, forKey: "lastUpdateDate")
        aCoder.encodeObject(color.rawValue, forKey: "color")
        aCoder.encodeObject(uuid, forKey: "uuid")
    }
    
    func toRecord() -> CKRecord {
        var record : CKRecord?
        
        if uuid == nil {
            record = CKRecord(recordType: "StatusEntity")
        } else {
            let recordID = CKRecordID(recordName: uuid)
            record = CKRecord(recordType: "StatusEntity", recordID: recordID)
        }
        record!.setObject(title, forKey: "title")
        record!.setObject(notes, forKey: "notes")
        record!.setObject(color.rawValue, forKey: "colorInt")
        record!.setObject(lastUpdateDate, forKey: "lastUpdateDate")
        
        return record!
    }
}
