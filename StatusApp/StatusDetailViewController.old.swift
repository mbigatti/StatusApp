//
//  StatusDetailViewController.swift
//  StatusApp
//
//  Created by Massimiliano Bigatti on 23/07/14.
//  Copyright (c) 2014 Massimiliano Bigatti. All rights reserved.
//

import UIKit
import BMXFlatButton
import QuartzCore

class StatusDetailViewController: UIViewController {

    var statusEntity : StatusEntity?
    
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var notestTextView: UITextView!
    
    @IBOutlet weak var button1: CircularButton!
    @IBOutlet weak var button2: CircularButton!
    @IBOutlet weak var button3: CircularButton!
    @IBOutlet weak var button4: CircularButton!
    @IBOutlet weak var button5: CircularButton!
    
    @IBOutlet weak var separator1Constraint: NSLayoutConstraint!
    @IBOutlet weak var separator2Constraint: NSLayoutConstraint!
    @IBOutlet weak var separator3Constraint: NSLayoutConstraint!
    @IBOutlet weak var separator4Constraint: NSLayoutConstraint!

    
    // MARK: - UIView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let buttons = [button1, button2, button3, button4, button5]
        var index = 0
        for button in buttons {
            button.normalColor = UIColor.colorForIndex(index)
            index++
        }
        
        titleTextView.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        notestTextView.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor = UIColor.colorForIndex(statusEntity!.colorIndex)
        
        titleTextView.text = statusEntity!.title
        notestTextView.text = statusEntity!.notes
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        let w = self.view.bounds.size.width -
            button1.frame.origin.x * 2 -
            button1.bounds.size.width -
            button2.bounds.size.width -
            button3.bounds.size.width -
            button4.bounds.size.width -
            button5.bounds.size.width
        
        let s = w / 4
        
        separator1Constraint.constant = s
        separator2Constraint.constant = s
        separator3Constraint.constant = s
        separator4Constraint.constant = s
        
        println("relayouting like a boss")
    }
    
    
    // MARK: - Actions
    
    @IBAction func colorButtonChanged(sender: UIButton)
    {
        statusEntity!.colorIndex = sender.tag
        changeColor()
    }
    
    @IBAction func confirmButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func viewTapped(sender: AnyObject)
    {
        titleTextView.resignFirstResponder()
        notestTextView.resignFirstResponder()
    }
    
    // MARK: - Privates
    
    func changeColor() {
        let animation = CABasicAnimation(keyPath: "backgroundColor")
        animation.toValue = UIColor.colorForIndex(statusEntity!.colorIndex).CGColor
        animation.delegate = self
        self.view.layer.addAnimation(animation, forKey: "fadeAnimation")
    }
    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        let animation = anim as CABasicAnimation
        let color = UIColor.colorForIndex(statusEntity!.colorIndex).CGColor
        self.view.backgroundColor = UIColor(CGColor: color)
    }
}
