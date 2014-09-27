//
//  StatusEntityDatabase.swift
//  StatusApp
//
//  Created by Massimiliano Bigatti on 25/09/14.
//  Copyright (c) 2014 Massimiliano Bigatti. All rights reserved.
//

import Foundation

class StatusEntityDatabase {
    
    class var sharedInstance : StatusEntityDatabase {
        struct Static {
            static let instance : StatusEntityDatabase = StatusEntityDatabase()
        }
        return Static.instance
    }
    
    private let databaseFilename = "entries.db"
    private let databaseFilePath : String
    
    lazy var entities : [StatusEntity] = {
        var data = NSKeyedUnarchiver.unarchiveObjectWithFile(sharedInstance.databaseFilePath) as? [StatusEntity]
        return data == nil ? [StatusEntity]() : data!.sorted({$0.title < $1.title})
    }()

    private init() {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true) as [NSString]
        databaseFilePath = paths[0].stringByAppendingPathComponent(databaseFilename)
        
        println("Using database file \(databaseFilePath)")
    }
    
    func addEntity(entity: StatusEntity) {
        entities.append(entity)
        entities = entities.sorted({
            $0.title < $1.title
        })
    }
    
    func removeEntityAtIndex(index: Int) {
        entities.removeAtIndex(index)
    }
    
    func synchronize() {
        NSKeyedArchiver.archiveRootObject(entities, toFile: databaseFilePath)
    }
}