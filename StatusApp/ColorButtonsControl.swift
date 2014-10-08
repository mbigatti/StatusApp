//
//  ColorsButtonView.swift
//  StatusApp
//
//  Created by Massimiliano Bigatti on 25/09/14.
//  Copyright (c) 2014 Massimiliano Bigatti. All rights reserved.
//

import UIKit

/// standard button size (width and height are equal as the button is a circle)
private let buttonWide = 44

/**
    Color buttons control. Manages a strip of five circular buttons, each one represent a color supported by the app.
 */
class ColorButtonsControl : UIControl
{
    
    // MARK: - Public Properties
    
    /// current selected colors
    var currentColor = StatusEntityColor.AZURE
    
    /// array of available buttons
    let buttons : [CircularButton] = [
        CircularButton(frame: CGRectZero),
        CircularButton(frame: CGRectZero),
        CircularButton(frame: CGRectZero),
        CircularButton(frame: CGRectZero),
        CircularButton(frame: CGRectZero)
    ];
    
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    /// common initialization
    private func commonInit() {
        var index = 0
        
        for button in buttons {
            button.borderWidth = 2
            button.normalColor = StatusEntityColor(rawValue: index)!.color()
            button.tag = index
            button.addTarget(self, action: "buttonTapped:", forControlEvents: .TouchUpInside)
            
            addSubview(button)
            index++
        }
        
        selectCurrentButton(buttons[0])
    }
    
    
    // MARK: - UIView
    
    /**     
        Layout the buttons leaving equal horizontal spacing between buttons and between buttons and containing view.
     */
    override func layoutSubviews() {
        let availableWidth = bounds.size.width
        let usedWidth = CGFloat(buttonWide * buttons.count)
        let remainingSpace = availableWidth - usedWidth
        let spacingX = Int(floor(remainingSpace / CGFloat(buttons.count + 1)))
        
        var x = spacingX
        
        for button in buttons {
            let rect = CGRect(x: Int(x), y: 0, width: buttonWide, height: buttonWide)
            button.frame = rect
            
            x += spacingX + buttonWide
        }
    }
    
    
    // MARK: - Actions
    
    /**
        Called when user taps on a button. The button is marked as selected, the current color property is updated and an event is raised to notify the containing view controller that content has changed.
    */
    @objc private func buttonTapped(sender : CircularButton) {
        selectCurrentButton(sender)
        currentColor = StatusEntityColor(rawValue: sender.tag)!
        sendActionsForControlEvents(.ValueChanged);
    }
    
    
    // MARK: - Privates
    
    /**
        Update appearance of selected button darkening the border color.
    
        :param: sender the `CircularButton` to mark as selected
    */
    private func selectCurrentButton(sender: CircularButton) {
        for button in buttons {
            button.borderColor = UIColor.blackColor().colorWithAlphaComponent(0.25)
        }
        sender.borderColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
    }
}