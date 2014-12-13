//
//  AppDelegate.swift
//  StatusApp
//
//  Created by Massimiliano Bigatti on 24/09/14.
//  Copyright (c) 2014 Massimiliano Bigatti. All rights reserved.
//

import UIKit
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        uploadToCloud()
        
        return true
    }

    /**
    checks if entities in the local database are already uploaded to iCloud
    */
    func uploadToCloud() {
        let entityDatabase = StatusEntityDatabase.sharedInstance
        
        for entity in entityDatabase.entities {
            if entity.uuid != nil {
                //
                // check if the record still exists in iCloud
                // it could be delete manually (for testing)
                //
                println("Checking iCloud entity UUID \(entity.uuid)")
                
                let recordID = CKRecordID(recordName: entity.uuid)
                let operation = CKFetchRecordsOperation(recordIDs: [recordID])
                operation.database = CKContainer.defaultContainer().privateCloudDatabase
                operation.perRecordCompletionBlock = { (currentRecord: CKRecord!, currentRecordID: CKRecordID!, error: NSError!) -> Void in
                    
                    if (error == nil) {
                        println("iCloud entity \(currentRecordID) is valid")
                        
                    } else {
                        println("iCloud entity \(currentRecordID) not found \(error)")
                        CloudSupport.createRecord(entity)
                    }
                }
                NSOperationQueue.mainQueue().addOperation(operation)
                
                continue;
            }

            CloudSupport.createRecord(entity)
        }
    }
}

