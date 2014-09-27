//
//  BMXGradientView.swift
//  BMXGradientView
//  https://github.com/mbigatti/BMXGradientView
//
//  Created by Massimiliano Bigatti on 21/07/14.
//  Copyright (c) 2014 Massimiliano Bigatti. All rights reserved.
//

import UIKit

public class GradientView : UIView {

    private let gradientBreakpoint = 0.85
    private let gradientPercentage = 0.025
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override init() {
        super.init()
    }
    
    public override func drawRect(rect: CGRect)
    {
        let context = UIGraphicsGetCurrentContext();
        
        let colorspace = CGColorSpaceCreateDeviceRGB();
        let color = self.backgroundColor!.darkerColor(gradientPercentage).CGColor
        let colors = [self.backgroundColor!.CGColor, self.backgroundColor!.CGColor, color] as CFArrayRef
        let locations = [ 0.0, gradientBreakpoint, 1.0 ] as [CGFloat]
        
        let gradient = CGGradientCreateWithColors(colorspace, colors, locations);
        
        let startPoint = CGPoint(x: 0, y: 0)
        let endPoint = CGPoint(x: 0, y: self.bounds.height)
        
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    }
}
