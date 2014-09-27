//
//  UnderlinedTextView.swift
//  StatusApp
//
//  Created by Massimiliano Bigatti on 26/09/14.
//  Copyright (c) 2014 Massimiliano Bigatti. All rights reserved.
//

import UIKit
import QuartzCore

class UnderlinedTextView : UIControl, UITextViewDelegate
{
    
    // MARK: - Public Properties
    
    var text : String {
        get {
            return textView.text
        }
        set {
            textView.text = newValue
        }
    }
    
    @IBOutlet var associatedLabel : UILabel?
    
    var activeColor : UIColor = UIColor.whiteColor() {
        didSet {
            updateActiveColor()
        }
    }
    
    var calculatedHeight : CGFloat {
        get {
            return textView.calculatedHeight()
        }
    }
    
    
    // MARK: - Private Properties
    
    private var textView = UITextView()
    private let underlineLayer = CALayer()
    
    private let underlineHighlightedHeight : CGFloat = 2
    private let underlineNormalHeight : CGFloat = 1

    
    // MARK: - Lifecycle
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        backgroundColor = UIColor.clearColor()
        layer.addSublayer(underlineLayer)
        
        textView.textColor = UIColor.whiteColor()
        textView.backgroundColor = UIColor.clearColor()     // UIColor.blackColor().colorWithAlphaComponent(0.5)
        textView.tintColor = UIColor.whiteColor()
        textView.font = UIFont.systemFontOfSize(17)
        textView.delegate = self
        textView.contentInset = UIEdgeInsets(top: -4, left: -4, bottom: 0, right: 0)
        
        addSubview(textView)
    }
    
    
    // MARK: - UIControl
    
    override func layoutSublayersOfLayer(layer: CALayer!) {
        super.layoutSublayersOfLayer(layer);
        
        if (layer == self.layer) {
            let h = textView.isFirstResponder() ? underlineHighlightedHeight : underlineNormalHeight
            let frame = CGRect(x: CGFloat(0), y: bounds.size.height - h, width: bounds.size.width, height: h);
            underlineLayer.frame = frame
        }
    }
    
    override func layoutSubviews() {
        let h = textView.isFirstResponder() ? underlineHighlightedHeight : underlineNormalHeight
        textView.frame = CGRect(origin: bounds.origin, size: CGSize(width: bounds.size.width, height: bounds.size.height - h))
        
        updateActiveColor()
    }
    
    
    // MARK: - UITextViewDelegate
    
    func textViewDidBeginEditing(textView: UITextView) {
        setNeedsLayout()
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        setNeedsLayout()
    }
    
    func textViewDidChange(textView: UITextView) {
        sendActionsForControlEvents(.ValueChanged)
    }
    
    
    // MARK: - Privates
    
    func updateActiveColor() {
        let color = textView.isFirstResponder() ? activeColor : UIColor.blackColor().colorWithAlphaComponent(0.5)
        underlineLayer.backgroundColor = color.CGColor
        
        if let label = associatedLabel {
            label.textColor = color
        }
    }
}

