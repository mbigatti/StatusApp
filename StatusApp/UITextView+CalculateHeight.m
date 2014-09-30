//
//  UITextView+CalculateHeight.m
//  ShopsApp
//
//  Created by Massimiliano Bigatti on 04/10/13.
//  Copyright (c) 2013 Massimiliano Bigatti. All rights reserved.
//

#import "UITextView+CalculateHeight.h"

@implementation UITextView (CalculateHeight)

/**
 @see https://github.com/HansPinckaers/GrowingTextView/blob/master/class/HPGrowingTextView.m
 */
- (CGFloat)calculatedHeight
{
    // The padding added around the text on iOS6 and iOS7 is different.
    //CGSize fudgeFactor = CGSizeMake(10.0, 16.0);
    CGSize fudgeFactor = CGSizeMake(6.0, 18.0);
    
    CGRect frame = self.bounds;
    frame.size.height -= fudgeFactor.height;
    frame.size.width -= fudgeFactor.width;
    
    NSMutableAttributedString* textToMeasure;
    
    if(self.attributedText && self.attributedText.length > 0) {
        textToMeasure = [[NSMutableAttributedString alloc] initWithAttributedString: self.attributedText];
        
    } else {
        NSString *text = (self.text.length == 0) ? @" " : self.text;
        textToMeasure = [[NSMutableAttributedString alloc] initWithString: text];
        [textToMeasure addAttribute: NSFontAttributeName
                              value: self.font
                              range: NSMakeRange(0, textToMeasure.length)];
    }
    
    if ([textToMeasure.string hasSuffix:@"\n"])
    {
        [textToMeasure appendAttributedString:[[NSAttributedString alloc] initWithString:@"-" attributes:@{NSFontAttributeName: self.font}]];
    }
    
    // NSAttributedString class method: boundingRectWithSize:options:context is
    // available only on ios7.0 sdk.
    CGRect size = [textToMeasure boundingRectWithSize: CGSizeMake(CGRectGetWidth(frame), MAXFLOAT)
                                              options: NSStringDrawingUsesLineFragmentOrigin
                                              context: nil];
    
    CGFloat height = CGRectGetHeight(size) + fudgeFactor.height;
    
    /*
    NSLog(@"self.bounds: %@", NSStringFromCGRect(self.bounds));
    NSLog(@"calculatedHeight: %3.f", height);
     */
    
    return height;
}
@end
