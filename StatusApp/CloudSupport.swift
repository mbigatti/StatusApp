//
//  CloudSupport.swift
//  StatusApp
//
//  Created by Massimiliano Bigatti on 13/12/14.
//  Copyright (c) 2014 Massimiliano Bigatti. All rights reserved.
//

import Foundation
import CloudKit

/**
 Utility extension to populate a CKRecord using a StatusEntity object
 */
extension CKRecord {
    func populateWithStatusEntity(entity : StatusEntity) {
        setObject(entity.title, forKey: "title")
        setObject(entity.notes, forKey: "notes")
        setObject(entity.color.rawValue, forKey: "colorInt")
        setObject(entity.lastUpdateDate, forKey: "lastUpdateDate")
    }
}

class CloudSupport {
   
    /**
     Create a new record on iCloud
     :param: entity the entity to be created
     */
    class func createRecord(entity: StatusEntity) {
        let record = CKRecord(recordType: "StatusEntity")
        record.populateWithStatusEntity(entity)
        
        CKContainer.defaultContainer().privateCloudDatabase.saveRecord(record) { (savedRecord: CKRecord!, error: NSError!) -> Void in
            
            if (error == nil) {
                entity.uuid = savedRecord.recordID.recordName
                StatusEntityDatabase.sharedInstance.synchronize()
                
                println("CloudSupport: created object \(entity.uuid)")
            } else {
                println("CloudSupport Error \(error)")
            }
        }
    }
    
    /**
     Update an existing record on iCloud
    :param: entity the entity to be updated
     */
    class func updateRecord(entity: StatusEntity) {
        let recordID = CKRecordID(recordName: entity.uuid)
        let record = CKRecord(recordType: "StatusEntity", recordID: recordID)
        record.populateWithStatusEntity(entity)
        
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        operation.savePolicy = .AllKeys
        operation.database = CKContainer.defaultContainer().privateCloudDatabase
        operation.perRecordCompletionBlock = { (currentRecord: CKRecord!, error: NSError!) -> Void in
            
            if (error == nil) {
                println("CloudSupport: updated object \(entity.uuid)")
            } else {
                println("CloudSupport Error \(error)")
            }
        }
        NSOperationQueue.mainQueue().addOperation(operation)
    }
}