//
//  ColorsButtonView.swift
//  StatusApp
//
//  Created by Massimiliano Bigatti on 25/09/14.
//  Copyright (c) 2014 Massimiliano Bigatti. All rights reserved.
//

import UIKit

private let buttonWidth = 44
private let buttonHeight = 44

class ColorButtonsControl : UIControl
{
    var currentColor = StatusEntityColor.AZURE
    
    let buttons : [CircularButton] = [
        CircularButton(frame: CGRectZero),
        CircularButton(frame: CGRectZero),
        CircularButton(frame: CGRectZero),
        CircularButton(frame: CGRectZero),
        CircularButton(frame: CGRectZero)
    ];
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        var index = 0
        
        for button in buttons {
            button.borderWidth = 2
            button.normalColor = StatusEntityColor.fromRaw(index)!.color()
            button.tag = index
            button.addTarget(self, action: "buttonTapped:", forControlEvents: .TouchUpInside)
            
            addSubview(button)
            index++
        }
        
        highlightCurrentButton(buttons[0])
    }
    
    private func highlightCurrentButton(sender: CircularButton) {
        for button in buttons {
            button.borderColor = UIColor.blackColor().colorWithAlphaComponent(0.25)
        }
        sender.borderColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
    }
    
    @objc
    private func buttonTapped(sender : CircularButton) {
        highlightCurrentButton(sender)
        currentColor = StatusEntityColor.fromRaw(sender.tag)!
        sendActionsForControlEvents(.ValueChanged);
    }
    
    override func layoutSubviews() {
        let availableWidth = bounds.size.width
        let usedWidth = CGFloat(buttonWidth * buttons.count)
        let remainingSpace = availableWidth - usedWidth
        let spacingX = Int(floor(remainingSpace / CGFloat(buttons.count + 1)))
        
        var x = spacingX
        
        for button in buttons {
            let rect = CGRect(x: Int(x), y: 0, width: buttonWidth, height: buttonHeight)
            button.frame = rect
            
            x += spacingX + buttonWidth
        }
    }
}