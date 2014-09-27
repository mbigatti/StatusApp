//
//  AddEntryIconView.swift
//  StatusApp
//
//  Created by Massimiliano Bigatti on 26/09/14.
//  Copyright (c) 2014 Massimiliano Bigatti. All rights reserved.
//

import UIKit

@IBDesignable class AddEntryButton : UIButton
{
    @IBInspectable let lineWidth : CGFloat = 2
    @IBInspectable let marginPercentage : CGFloat = 0.3
    @IBInspectable let normalButtonColor : UIColor = UIColor.whiteColor()
    @IBInspectable let highlightedButtonColor : UIColor = UIColor.whiteColor().colorWithAlphaComponent(0.75)

    override var highlighted : Bool {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func drawRect(rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        let color = highlighted ? highlightedButtonColor : normalButtonColor
        
        /*
        if highlighted {
            CGContextSetFillColorWithColor(context, highlightedButtonColor.CGColor)
            CGContextFillEllipseInRect(context, bounds)
        }
        */
        
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
        let pi = 3.141592653589793
        
        CGContextAddArc(context, x, y, r, CGFloat(0), CGFloat(2 * pi), 1)
        
        CGContextMoveToPoint(context, x, y0)
        CGContextAddLineToPoint(context, x, y1)
        
        CGContextMoveToPoint(context, x0, y)
        CGContextAddLineToPoint(context, x1, y)
        
        CGContextStrokePath(context)
    }
}
