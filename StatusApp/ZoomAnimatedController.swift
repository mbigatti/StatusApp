//
//  ZoomingViewControllerAnimatedTransitioning.swift
//  StatusApp
//
//  Created by Massimiliano Bigatti on 30/09/14.
//  Copyright (c) 2014 Massimiliano Bigatti. All rights reserved.
//

import Foundation

class ZoomAnimatedController : NSObject, UIViewControllerAnimatedTransitioning
{
    var presenting = true
    var animatingIndexPath : NSIndexPath?
    
    /// duration of the animation
    private let animationDuration : Double = 0.35
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return animationDuration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if presenting {
            animatePresenting(transitionContext)
        } else {
            animateDismissing(transitionContext)
        }
    }
    
    func animatePresenting(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as UITableViewController!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        //
        // configure the destination controller initial frame
        //
        let tableView = fromViewController.tableView
        animatingIndexPath = tableView.indexPathForSelectedRow()
        if animatingIndexPath == nil {
            let lastRow = tableView.dataSource!.tableView(tableView, numberOfRowsInSection: 0) - 1
            animatingIndexPath = NSIndexPath(forRow: lastRow, inSection: 0)
            toViewController.view.backgroundColor = UIColor.blackColor()
        }
        let originFrame = tableView.rectForRowAtIndexPath(animatingIndexPath!)
        toViewController.view.frame = originFrame
        
        //
        // add destination controller to content view
        //
        toViewController.view.clipsToBounds = true
        transitionContext.containerView().addSubview(toViewController.view)
        
        //
        // perform animation
        //
        tableView.cellForRowAtIndexPath(self.animatingIndexPath!)?.contentView.alpha = 0
        
        UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: { () -> Void in
            toViewController.view.frame = transitionContext.finalFrameForViewController(toViewController)
            //fromViewController.view.transform = CGAffineTransformMakeTranslation(-toViewController.view.frame.size.width, 0)
            
        }) { (finished) -> Void in
            //
            // restore original properties and complete transition
            //
            //fromViewController.view.transform = CGAffineTransformIdentity
            tableView.cellForRowAtIndexPath(self.animatingIndexPath!)?.contentView.alpha = 1
            toViewController.view.clipsToBounds = false
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
    
    func animateDismissing(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as UITableViewController!
        
        transitionContext.containerView().addSubview(toViewController.view)
        transitionContext.containerView().bringSubviewToFront(fromViewController.view)
        
        fromViewController.view.clipsToBounds = true
        let tableView = toViewController.tableView
        tableView.cellForRowAtIndexPath(self.animatingIndexPath!)?.contentView.alpha = 0
        
        //
        // perform animation
        //
        UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: { () -> Void in
            let frame = tableView.rectForRowAtIndexPath(self.animatingIndexPath!)
            fromViewController.view.frame = frame
            
        }) { (finished) -> Void in
            //
            // restore original properties and complete transition
            //
            tableView.cellForRowAtIndexPath(self.animatingIndexPath!)?.contentView.alpha = 1
            fromViewController.view.clipsToBounds = false
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
}