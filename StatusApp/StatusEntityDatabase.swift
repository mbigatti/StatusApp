//
//  StatusEntityDatabase.swift
//  StatusApp
//
//  Created by Massimiliano Bigatti on 25/09/14.
//  Copyright (c) 2014 Massimiliano Bigatti. All rights reserved.
//

import Foundation

/**
    Contains of all the entries stored in the app.
    The database is a simple `NSKeyedArchiver` file. The entities are returned orderder by title.
 */
class StatusEntityDatabase {
    
    /// singleton
    class var sharedInstance : StatusEntityDatabase {
        struct Static {
            static let instance : StatusEntityDatabase = StatusEntityDatabase()
        }
        return Static.instance
    }
    
    /// database file name
    private let databaseFilename = "entries.db"
    
    /// database file path complete of file name
    private let databaseFilePath : String
    
    /// array of entities contained in the database
    lazy var entities : [StatusEntity] = {
        var data = NSKeyedUnarchiver.unarchiveObjectWithFile(sharedInstance.databaseFilePath) as? [StatusEntity]
        return data == nil ? [StatusEntity]() : data!.sorted({$0.title < $1.title})
    }()

    /**
        Private initializer. Inits the `databaseFilePath` property
     */
    private init() {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true) as [NSString]
        databaseFilePath = paths[0].stringByAppendingPathComponent(databaseFilename)
        
        // dumps complete database file path for debugging purposes
        println("Using database file \(databaseFilePath)")
    }
    
    /**
        Add an entity
    
        :param: entity entity to be added
     */
    func addEntity(entity: StatusEntity) {
        entities.append(entity)
        entities = entities.sorted({
            $0.title < $1.title
        })
    }
    
    /**
        Removes the entity at specified index
    
        :param: index index of entity to be removed
     */
    func removeEntityAtIndex(index: Int) {
        entities.removeAtIndex(index)
    }
    
    /**
        Saves pending changes to the permanent storage
     */
    func synchronize() {
        NSKeyedArchiver.archiveRootObject(entities, toFile: databaseFilePath)
    }
}