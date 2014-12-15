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

 iCloud Synchronizer using CloudKit

 */
class CloudSynchronizer {
    let entityDatabase = StatusEntityDatabase.sharedInstance
    
    /// singleton
    class var sharedInstance : CloudSynchronizer {
        struct Static {
            static let instance = CloudSynchronizer()
        }
        return Static.instance
    }
    
    func sync() {
        cloudStatus.postNotifications = true
        
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let query = CKQuery(recordType: "StatusEntity", predicate: predicate)
        
        CKContainer.defaultContainer().privateCloudDatabase.performQuery(
            query, inZoneWithID: nil) { (results: [AnyObject]!, error: NSError!) -> Void in
                if error == nil {
                    //
                    // download
                    //
                    println("Remote elements count \(results.count)")
                    
                    for record in results as [CKRecord] {
                        let uuid = record.recordID.recordName
                        println("Checking remote UUID \(uuid!)")
                        
                        let filtered = self.entityDatabase.entities.filter({ (element: StatusEntity) -> Bool in
                            return element.uuid == uuid
                        })
                        
                        if filtered.count == 0 {
                            //
                            // remote record not present in local database
                            //
                            println("  element not present locally, adding \(record) to local database")
                            let entity = StatusEntity(record: record)
                            self.entityDatabase.addEntity(entity)
                            self.entityDatabase.synchronize()
                            
                        } else {
                            println("  element already present locally")
                        }
                    }
                    
                    //
                    // upload
                    //
                    for entity in self.entityDatabase.entities {
                        println("Checking local UUID \(entity.uuid)")
                        
                        var doUpload = false
                        
                        if entity.uuid == nil {
                            doUpload = true
                            
                        } else {
                            //
                            // check if the record still exists in iCloud
                            // it could be delete manually (for testing)
                            //
                            let filtered = results.filter({ (element) -> Bool in
                                return (element as CKRecord).recordID.recordName == entity.uuid
                            })
                            
                            if filtered.count == 0 {
                                println("  Element not present remotely")
                                doUpload = true
                            }
                        }
                        
                        if doUpload {
                            self.createRecord(entity)
                        }
                    }
                    
                } else {
                    self.logError(error)
                }
                
                cloudStatus.decrementPendingRequest()
        }
        
        cloudStatus.incrementPendingRequest()
    }
    
    /**
     Create a new record on iCloud
     :param: entity the entity to be created
     */
    func createRecord(entity: StatusEntity) {
        let record = entity.toRecord()
        
        CKContainer.defaultContainer().privateCloudDatabase.saveRecord(record) { (savedRecord: CKRecord!, error: NSError!) -> Void in
            
            if (error == nil) {
                if entity.uuid == nil {
                    entity.uuid = savedRecord.recordID.recordName
                    StatusEntityDatabase.sharedInstance.synchronize()
                    println("Created remote object with UUID \(entity.uuid)")
                    
                } else {
                    println("Updated remote object with UUID \(entity.uuid)")
                }
                
            } else {
                self.logError(error)
            }
            
            cloudStatus.decrementPendingRequest()
        }
        
        cloudStatus.incrementPendingRequest()
    }
    
    /**
     Update an existing record on iCloud
    :param: entity the entity to be updated
     */
    func updateRecord(entity: StatusEntity) {
        let record = entity.toRecord()
        
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        operation.savePolicy = .AllKeys
        operation.database = CKContainer.defaultContainer().privateCloudDatabase
        operation.perRecordCompletionBlock = { (currentRecord: CKRecord!, error: NSError!) -> Void in
            
            if (error == nil) {
                println("Updated remote object with UUID \(entity.uuid)")
                
            } else {
                self.logError(error)
            }
            
            cloudStatus.decrementPendingRequest()
        }
        
        NSOperationQueue.mainQueue().addOperation(operation)
        cloudStatus.incrementPendingRequest()
    }
    
    func deleteRecordWithUUID(uuid : String) {
        let recordID = CKRecordID(recordName: uuid)
        CKContainer.defaultContainer().privateCloudDatabase.deleteRecordWithID(recordID) { (currentRecordID: CKRecordID!, error: NSError!) -> Void in
            if (error == nil) {
                println("Deleted remote object with UUID \(recordID)")
                
            } else {
                self.logError(error)
            }
            
            cloudStatus.decrementPendingRequest()
        }
    }
    
    private func logError(error: NSError) {
        println("iCloud remote error \(error)")
    }
}

let cloudStatus = CloudStatus()

class CloudStatus {
    private var pendingRequests = 0;
    var postNotifications = false;
    
    func incrementPendingRequest() {
        pendingRequests++
    }
    
    func decrementPendingRequest() {
        pendingRequests--
        
        if pendingRequests == 0 && postNotifications {
            NSNotificationCenter.defaultCenter().postNotificationName(StatusAppDidUpdateFromCloud, object: nil)
        }
    }
}