//
//  AddEntryButton.swift
//  StatusApp
//
//  Created by Massimiliano Bigatti on 26/09/14.
//  Copyright (c) 2014 Massimiliano Bigatti. All rights reserved.
//

import UIKit

/**
 Add Entry Button
 */
@IBDesignable class AddEntryButton : UIButton
{
    /// icon line width
    @IBInspectable let lineWidth : CGFloat = 2
    
    /// percentage of space to be left empty between the external circle and the internal plus icon
    @IBInspectable let marginPercentage : CGFloat = 0.3
    
    /// normal button color, defaults to white
    @IBInspectable let normalButtonColor : UIColor = UIColor.whiteColor()
    
    /// highlighted button color, defaults to 75% white
    @IBInspectable let highlightedButtonColor : UIColor = UIColor.whiteColor().colorWithAlphaComponent(0.75)

    /// `highlighted` property override to redisplay the button when it changes state
    override var highlighted : Bool {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /**
     Draws the button icon, composed by an external circle and a plus button.
     */
    override func drawRect(rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        let color = highlighted ? highlightedButtonColor : normalButtonColor
        
        CGContextSetStrokeColorWithColor(context, color.CGColor)
        CGContextSetLineCap(context, kCGLineCapRound)
        CGContextSetLineWidth(context, lineWidth)
        
        let x = bounds.size.width / 2
        let y0 = bounds.size.height * marginPercentage
        let y1 = bounds.size.height - y0
        
        let y = bounds.size.height / 2
        let x0 = bounds.size.width * marginPercentage
        let x1 = bounds.size.width - x0
        
        let r = bounds.size.width / 2 - lineWidth
        
        CGContextAddArc(context, x, y, r, CGFloat(0), CGFloat(2 * M_PI), 1)
        
        CGContextMoveToPoint(context, x, y0)
        CGContextAddLineToPoint(context, x, y1)
        
        CGContextMoveToPoint(context, x0, y)
        CGContextAddLineToPoint(context, x1, y)
        
        CGContextStrokePath(context)
    }
}
