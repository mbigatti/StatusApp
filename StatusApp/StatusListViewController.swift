//
//  ViewController.swift
//  StatusApp
//
//  Created by Massimiliano Bigatti on 10/07/14.
//  Copyright (c) 2014 Massimiliano Bigatti. All rights reserved.
//

import UIKit

/**
 Status Main View Controller
 */
class StatusListViewController: UITableViewController, UIViewControllerTransitioningDelegate {
    /// entity database reference
    let entityDatabase = StatusEntityDatabase.sharedInstance
    
    /// data source used when no data is present
    let emptyDataSource = EmtpyStatusListDataSource()
    
    /// data source used when at least one entry is present
    let normalDataSource = NormalStatusListDataSource()
    
    /// current data source
    var currentDataSource : UITableViewDataSource!
    
    private var animationController = ZoomAnimatedController()
    

    // MARK: - UIViewController
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // this is required to avoid strange row height change on rotation or view appear
        tableView.estimatedRowHeight = 60
        
        determineCurrentDataSource()
        
        // required to correctly size cells when exit segue from detail view
        tableView.reloadData()
    }
    
    
    // MARK: - Actions

    /**
     Add button was tapped
     */
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
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return indexPath.isEntityIndexPath() ? indexPath : nil
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showDetail", sender: indexPath)
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.isEntityIndexPath()
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        //
        // delete the entry
        //
        if editingStyle == .Delete {
            entityDatabase.removeEntityAtIndex(indexPath.row)
            entityDatabase.synchronize()
          
            // update table
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
            
            // update current data source
            determineCurrentDataSource()
        }
    }
    
    
    // MARK: - UIViewControllerTransitioningDelegate
    
    func animationControllerForPresentedController(presented: UIViewController,
        presentingController presenting: UIViewController,
        sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        animationController.presenting = true
        return animationController
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animationController.presenting = false
        return animationController
    }
    
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            let destinationController = segue.destinationViewController as StatusDetailViewController
            destinationController.transitioningDelegate = self

            // editing an existent item
            if sender is NSIndexPath {
                let indexPath = sender as NSIndexPath
                destinationController.currentStatusEntity = entityDatabase.entities[indexPath.row]
            }
        }
    }
    
    
    // MARK - Privates
    
    /**
     Update the currentDataSource property with correct data source (normal or empty). If the data source
     changed, reload the table view data to update the display.
     */
    private func determineCurrentDataSource() {
        let newDataSource : UITableViewDataSource = entityDatabase.entities.count == 0 ? emptyDataSource : normalDataSource
        if newDataSource !== currentDataSource {
            currentDataSource = newDataSource
            tableView.reloadData()
        }
    }

}


// MARK: - EmtpyStatusListDataSource

/**
`UITableViewDataSource` that provide placeholder content and an Add button (empty state)
*/
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

/**
 `UITableViewDataSource` that provide access to the contents of the `StatusEntityDatabase` and an Add button.
 */
class NormalStatusListDataSource : NSObject, UITableViewDataSource
{
    let entityDatabase = StatusEntityDatabase.sharedInstance
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entityDatabase.entities.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.isAddEntityIndexPath() {
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

/**
 Utility extension
 */
extension NSIndexPath {
    
    /// :returns: `true` if the `indexPath` represent a normal entity
    func isEntityIndexPath() -> Bool {
        return self.row != StatusEntityDatabase.sharedInstance.entities.count
    }
    
    /// :returns: `true` if the `indexPath` represent the add button cell
    func isAddEntityIndexPath() -> Bool {
        return !isEntityIndexPath()
    }
    
}
