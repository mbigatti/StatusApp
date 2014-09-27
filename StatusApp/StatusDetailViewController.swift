//
//  StatusDetailViewController.swift
//  StatusApp
//
//  Created by Massimiliano Bigatti on 24/09/14.
//  Copyright (c) 2014 Massimiliano Bigatti. All rights reserved.
//

import UIKit
import QuartzCore

class StatusDetailViewController : UIViewController {
    
    // MARK: - Properties
    
    let entityDatabase = StatusEntityDatabase.sharedInstance
    var statusEntity : StatusEntity?
    
    @IBOutlet private weak var titleTextView: UnderlinedTextView!
    @IBOutlet private weak var notesTextView: UnderlinedTextView!
    @IBOutlet private weak var colorButtonsControl: ColorButtonsControl!
    @IBOutlet private weak var doneButton: UIButton!
    
    @IBOutlet weak var notesTextViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - UIViewController
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI()
        validateForm()
        
        titleTextView.becomeFirstResponder()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        adjustTextViewHeight()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    // MARK: - Actions
    
    @IBAction func colorSelectionChanged(sender: UIControl) {
        updateActiveColors()
        changeBackgroundColor()
    }
    
    @IBAction func titleTextViewChanged(sender: UnderlinedTextView) {
        validateForm()
    }
    
    @IBAction func notesTextViewChanged(sender: UnderlinedTextView) {
        adjustTextViewHeight()
    }
    
    @IBAction func viewTapped(sender: AnyObject) {
        titleTextView.resignFirstResponder()
        notesTextView.resignFirstResponder()
    }
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        if let entity = statusEntity {
            // update entity
            entity.title = titleTextView.text
            entity.notes = notesTextView.text
            entity.color = colorButtonsControl.currentColor
            
        } else {
            // create a new entity
            let entity = StatusEntity(title: titleTextView.text, notes: notesTextView.text, color: colorButtonsControl.currentColor)
            entityDatabase.addEntity(entity)
        }
        
        // save data on disk
        entityDatabase.synchronize()
        
        // dismiss controller
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    
    // MARK: - Privates
    
    private func updateUI() {
        if let entity = statusEntity {
            titleTextView.text = entity.title
            notesTextView.text = entity.notes
            notesTextView.sizeToFit()
            colorButtonsControl.currentColor = entity.color
            view.backgroundColor = entity.color.color()
            
        } else {
            view.backgroundColor = StatusEntityColor.AZURE.color()
        }
        
        updateActiveColors()
    }
    
    private func adjustTextViewHeight() {
        notesTextViewHeightConstraint.constant = notesTextView.calculatedHeight
    }
    
    private func validateForm() {
        if let textView = titleTextView {
            let text = textView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            let valid = countElements(text) != 0
            
            doneButton.enabled = valid
        }
    }
    
    private func updateActiveColors() {
        var activeColor : StatusEntityColor
        
        switch (colorButtonsControl.currentColor) {
        case .AZURE:
            activeColor = .MAGENTA
        case .GREEN:
            activeColor = .MAGENTA
        case .YELLOW:
            activeColor = .RED
        case .RED:
            activeColor = .YELLOW
        case .MAGENTA:
            activeColor = .AZURE
        }
    
        titleTextView.activeColor = activeColor.color()
        notesTextView.activeColor = activeColor.color()
    }
    
    private func changeBackgroundColor() {
        let animation = CABasicAnimation(keyPath: "backgroundColor")
        
        animation.duration = 0.35
        animation.toValue = colorButtonsControl.currentColor.color().CGColor
        animation.removedOnCompletion = false
        animation.delegate = self
        
        self.view.layer.addAnimation(animation, forKey: "fadeAnimation")
    }
    
    
    // MARK : - CAAnimation Delegate
    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        self.view.layer.backgroundColor = colorButtonsControl.currentColor.color().CGColor
    }
    
}