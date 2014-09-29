//
//  StatusAppColors.swift
//  StatusApp
//
//  Created by Massimiliano Bigatti on 24/09/14.
//  Copyright (c) 2014 Massimiliano Bigatti. All rights reserved.
//

import UIKit

/**
 Colors supported by the app
 */
enum StatusEntityColor : Int {
    case AZURE
    case GREEN
    case YELLOW
    case RED
    case MAGENTA
    
    /// array of supported colors
    static let colors = [
        RED:        UIColor.colorWithRGB(0xE86751),
        AZURE:      UIColor.colorWithRGB(0x3AEBFF),
        GREEN:      UIColor.colorWithRGB(0x82E83F),
        YELLOW:     UIColor.colorWithRGB(0xFFC43B),
        MAGENTA:    UIColor.colorWithRGB(0xCA5FFF),
    ]
    
    /**
     :returns: `UIColor` associated to this color
    */
    func color() -> UIColor {
        if let color = StatusEntityColor.colors[self] {
            return color
        } else {
            return UIColor.clearColor()
        }
    }
}
