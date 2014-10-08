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
    
    /// layer used to animate background color
    private var colorLayer = CALayer()
    
    /// current view translation on y axis
    private var currentTranslationY : CGFloat = 0
    
    /// keyboard frame
    private var keyboardEndFrame : CGRect?

    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layer.insertSublayer(colorLayer, atIndex: 0)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        colorLayer.frame = self.view.layer.bounds
        
        registerNotifications()
        
        updateUI()
        validateForm()
        
        titleTextView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        hideKeyboard()
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        unregisterNotifications()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func layoutSublayersOfLayer(layer: CALayer!) {
        if layer === self.view.layer {
            colorLayer.frame = layer.bounds
        }
    }

    /** 
        This is required when editing existing items, to size the text view correctly. It is also called on rotation, but the height change is already correct by the viewWillTransitionToSize animation.
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustTextViewHeight()
    }
    
    /**
        Manage rotations adjusting notes text view height
     */
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        // compute current notes text view margins
        let destinationTextViewWidth = size.width - (self.view.bounds.size.width - notesTextView.bounds.width)
        
        coordinator.animateAlongsideTransition({ (context: UIViewControllerTransitionCoordinatorContext!) in
            //
            // force size of notes text view to obtain the correct
            let newSize = CGSize(width: destinationTextViewWidth, height: self.notesTextView.bounds.size.height)
            self.notesTextView.frame = CGRect(origin: self.notesTextView.frame.origin, size: newSize)
            
            // adjust height and animate
            self.adjustTextViewHeight()
            self.view.setNeedsLayout()
        }, completion: nil)
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
        hideKeyboard()
    }
    
    /// called when the user drag the view
    @IBAction func viewPanned(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(view)
        let newTranslationY = currentTranslationY + translation.y
        
        // does not scroll view up
        if currentTranslationY + translation.y >= 0 {
            return;
        }
        
        // does not scroll past the keyboard
        if -newTranslationY > keyboardEndFrame?.size.height {
            return;
        }
    
        if sender.state == UIGestureRecognizerState.Began || sender.state == UIGestureRecognizerState.Changed {
            view.transform = CGAffineTransformMakeTranslation(0, newTranslationY)
        }
        
        if sender.state == .Ended {
            currentTranslationY = newTranslationY
        }
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

    
    // MARK: - Notifications
    
    func registerNotifications() {
        let nc = NSNotificationCenter.defaultCenter()
        
        nc.addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        nc.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unregisterNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardDidShow(notification : NSNotification) {
        let userInfo = notification.userInfo! as NSDictionary
        keyboardEndFrame = userInfo.objectForKey(UIKeyboardFrameEndUserInfoKey)!.CGRectValue()
    }
    
    /**
        Called when the keyboard is hidden. In this case animate back in position the view if it is required
     */
    func keyboardWillHide(notification : NSNotification) {
        keyboardEndFrame = nil
        
        let userInfo = notification.userInfo! as NSDictionary
        let duration = userInfo.objectForKey(UIKeyboardAnimationDurationUserInfoKey)!.doubleValue
        
        UIView.animateWithDuration(duration) {
            self.view.transform = CGAffineTransformIdentity
            self.currentTranslationY = 0
        }
    }
    
    
    // MARK: - Privates
    
    /**
        Updates UI populating the text fields with current entity data and configuring the view background color. If we're inserting a new entity, defaults to AZURE background color.
     */
    private func updateUI() {
        if let entity = currentStatusEntity {
            titleTextView.text = entity.title
            notesTextView.text = entity.notes
            notesTextView.sizeToFit()
            colorButtonsControl.currentColor = entity.color
            colorLayer.backgroundColor = entity.color.color().CGColor
            
        } else {
            colorLayer.backgroundColor = StatusEntityColor.AZURE.color().CGColor
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
        Hide the keybaord (if present), resigning first responder on both input text views.
     */
    private func hideKeyboard() {
        titleTextView.resignFirstResponder()
        notesTextView.resignFirstResponder()
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
            activeColor = .RED
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
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.35)
        
        colorLayer.backgroundColor = colorButtonsControl.currentColor.color().CGColor
        
        CATransaction.commit()
    }
    
}