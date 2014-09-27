//
//  ViewController.swift
//  StatusApp
//
//  Created by Massimiliano Bigatti on 10/07/14.
//  Copyright (c) 2014 Massimiliano Bigatti. All rights reserved.
//

import UIKit

class StatusListViewController: UITableViewController {
    let entityDatabase = StatusEntityDatabase.sharedInstance
    
    let emptyDataSource = EmtpyStatusListDataSource()
    let normalDataSource = NormalStatusListDataSource()
    var currentDataSource : UITableViewDataSource!
    
    // MARK: - UIViewController
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // required to correctly size cells when exit segue from detail view
    override func viewWillAppear(animated: Bool) {
        determineCurrentDataSource()
        tableView.reloadData()
    }
    
    // required to correctly size cells when exit segue from detail view
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        tableView.reloadData()
    }
    
    
    // MARK: - Actions
    
    @IBAction func addButtonTapped(sender: AnyObject) {
        performSegueWithIdentifier("showDetail", sender: sender)
    }
    
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentDataSource.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return currentDataSource.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
    
    
    // MARK: - UITableViewDelegate
    
    /*
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.isAddRow() {
            return 80;
        } else {
            return UITableViewAutomaticDimension;
        }
    }
    */
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return indexPath.isEntityRow() ? indexPath : nil
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showDetail", sender: indexPath)
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.isEntityRow()
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            entityDatabase.removeEntityAtIndex(indexPath.row)
            entityDatabase.synchronize()
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
            
            determineCurrentDataSource()
        }
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            let destinationController = segue.destinationViewController as StatusDetailViewController
            
            if sender is NSIndexPath {
                let indexPath = sender as NSIndexPath
                destinationController.statusEntity = entityDatabase.entities[indexPath.row]
            } else {
                // add new
            }
        }
    }
    
    
    // MARK - Privates
    
    func determineCurrentDataSource() {
        let newDataSource : UITableViewDataSource = entityDatabase.entities.count == 0 ? emptyDataSource : normalDataSource
        if newDataSource !== currentDataSource {
            currentDataSource = newDataSource
            tableView.reloadData()
        }
    }

}


// MARK: - EmtpyStatusListDataSource

class EmtpyStatusListDataSource : NSObject, UITableViewDataSource
{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = indexPath.row == 0 ? "StatusListEmptyCell" : "StatusListAddCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as UITableViewCell
        cell.selectionStyle = .None
        return cell
    }
}


// MARK: - NormalStatusListDataSource

class NormalStatusListDataSource : NSObject, UITableViewDataSource
{
    let entityDatabase = StatusEntityDatabase.sharedInstance
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entityDatabase.entities.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.isAddRow() {
            let cell = tableView.dequeueReusableCellWithIdentifier("StatusListAddCell") as UITableViewCell
            cell.selectionStyle = .None
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("StatusListViewCell") as StatusListViewCell
            
            let entity = entityDatabase.entities[ indexPath.row ]
            cell.configureForStatusEntity(entity)
            cell.setNeedsLayout()
            
            return cell
        }
    }
}


// MARK: - NSIndexPath utility extension

extension NSIndexPath {
    
    func isEntityRow() -> Bool {
        return self.row != StatusEntityDatabase.sharedInstance.entities.count
    }
    
    func isAddRow() -> Bool {
        return !isEntityRow()
    }
    
}
