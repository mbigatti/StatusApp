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
    var originFrame = CGRectZero
    
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
        originFrame = tableView.rectForRowAtIndexPath(tableView.indexPathForSelectedRow()!)
        toViewController.view.frame = originFrame
        
        //
        // add destination controller to content view
        //
        toViewController.view.clipsToBounds = true
        transitionContext.containerView().addSubview(toViewController.view)
        
        //
        // perform animation
        //
        UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: { () -> Void in
            toViewController.view.frame = transitionContext.finalFrameForViewController(toViewController)
            
        }) { (finished) -> Void in
            //
            // restore original properties and complete transition
            //
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
        
        //
        // perform animation
        //
        UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: { () -> Void in
            fromViewController.view.frame = CGRectInset(self.originFrame, 0, tableView.contentOffset.y)
            
        }) { (finished) -> Void in
            //
            // restore original properties and complete transition
            //
            fromViewController.view.clipsToBounds = false
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
}