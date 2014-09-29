//
//  StatusDetailViewController.swift
//  StatusApp
//
//  Created by Massimiliano Bigatti on 24/09/14.
//  Copyright (c) 2014 Massimiliano Bigatti. All rights reserved.
//

import UIKit
import QuartzCore

/**
 Status Detail View Controller
 */
class StatusDetailViewController : UIViewController {
    
    // MARK: - Properties
    
    /// reference to the entities database
    let entityDatabase = StatusEntityDatabase.sharedInstance
    
    /// current entity entry
    var currentStatusEntity : StatusEntity?
    
    /// reference to the title text view
    @IBOutlet private weak var titleTextView: UnderlinedTextView!
    
    /// reference to the notes text view
    @IBOutlet private weak var notesTextView: UnderlinedTextView!
    
    /// reference to the color button array control
    @IBOutlet private weak var colorButtonsControl: ColorButtonsControl!
    
    /// reference to the Done button
    @IBOutlet private weak var doneButton: UIButton!
    
    /// reference to the notes text view height constraint, used to implement auto-growth
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

        // FIXME: should be in the viewWillAppear callback method but it does not work when editing existing entries
        adjustTextViewHeight()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    // MARK: - Actions
    
    /// called when user changes color selection
    @IBAction func colorSelectionChanged(sender: UIControl) {
        updateActiveColor()
        changeBackgroundColor()
    }
    
    /// called when title text view content changes
    @IBAction func titleTextViewChanged(sender: UnderlinedTextView) {
        validateForm()
    }
    
    /// called when notes text view content changes
    @IBAction func notesTextViewChanged(sender: UnderlinedTextView) {
        adjustTextViewHeight()
    }
    
    /// called when the user taps on the view
    @IBAction func viewTapped(sender: AnyObject) {
        titleTextView.resignFirstResponder()
        notesTextView.resignFirstResponder()
    }
    
    /// called when the user taps on the Done button
    @IBAction func doneButtonTapped(sender: AnyObject) {
        if let entity = currentStatusEntity {
            //
            // update entity contents
            //
            entity.title = titleTextView.text
            entity.notes = notesTextView.text
            entity.color = colorButtonsControl.currentColor
            
        } else {
            //
            // create a new entity
            //
            let entity = StatusEntity(title: titleTextView.text, notes: notesTextView.text, color: colorButtonsControl.currentColor)
            entityDatabase.addEntity(entity)
        }
        
        // save data in the archive file
        entityDatabase.synchronize()
        
        // dismiss controller
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /// called when the user taps on the Cancel button
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    
    // MARK: - Privates
    
    /**
     Updates UI populating the text fields with current entity data and configuring the view background color.
     If we're inserting a new entity, defaults to the `AZURE` background color.
     */
    private func updateUI() {
        if let entity = currentStatusEntity {
            titleTextView.text = entity.title
            notesTextView.text = entity.notes
            notesTextView.sizeToFit()
            colorButtonsControl.currentColor = entity.color
            view.backgroundColor = entity.color.color()
            
        } else {
            view.backgroundColor = StatusEntityColor.AZURE.color()
        }
        
        updateActiveColor()
    }
    
    /**
     Updates notes text view height (auto-grown)
     */
    private func adjustTextViewHeight() {
        notesTextViewHeightConstraint.constant = notesTextView.calculatedHeight
    }
    
    /**
     Validate the form and update the Done button `enabled` state. The form is considered valid if the title contains at least one character and it is not a whitespace or newline character.
     */
    private func validateForm() {
        if let textView = titleTextView {
            let text = textView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            let valid = countElements(text) != 0
            
            doneButton.enabled = valid
        }
    }
    
    /**
     Update form active color. This is a color that contrasts with the view background color and it is used to highligth the current text field.
     */
    private func updateActiveColor() {
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
    
    /**
     Animate the change of the view background color to the current color in the `ColorButtonsControl` control.
     */
    private func changeBackgroundColor() {
        let animation = CABasicAnimation(keyPath: "backgroundColor")
        
        animation.duration = 0.35
        animation.toValue = colorButtonsControl.currentColor.color().CGColor
        animation.removedOnCompletion = false
        animation.delegate = self
        
        self.view.layer.addAnimation(animation, forKey: "fadeAnimation")
    }
    
    
    // MARK : - CAAnimation Delegate
    
    /// callback method sticks the view background color after the end of the animation
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        self.view.layer.backgroundColor = colorButtonsControl.currentColor.color().CGColor
    }
    
}