//
//  AppDelegate.swift
//  StatusApp
//
//  Created by Massimiliano Bigatti on 24/09/14.
//  Copyright (c) 2014 Massimiliano Bigatti. All rights reserved.
//

import UIKit
import CloudKit

let StatusAppDidUpdateFromCloud = "StatusAppDidUpdateFromCloud"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        CloudSynchronizer.sharedInstance.sync()
        
        return true
    }
    
}

