//
//  JJLabel.h
//  BreezyReader2
//
//  Created by 金 津 on 12-2-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    JJTextVerticalAlignmentTop,
    JJTextVerticalAlignmentMiddle,
    JJTextVerticalAlignmentBottom
} JJTextVerticalAlignment;

@interface JJLabel : UIView{
    UIEdgeInsets _insets;
}

-(void)setContentEdgeInsets:(UIEdgeInsets)insets;
-(void)resizeToFitText;

@property (nonatomic, assign) CGFloat shadowBlur;
@property (nonatomic, assign) CGFloat shadowEnable;
@property (nonatomic, retain) UIColor* shadowColor;
@property (nonatomic, assign) CGSize shadowOffset;
@property (nonatomic, retain) UIFont* font;
@property (nonatomic, retain) UIColor* textColor;

@property (nonatomic, copy) NSString* text;
@property (nonatomic, assign) UITextAlignment textAlignment;

@property (nonatomic, assign) JJTextVerticalAlignment verticalAlignment;

@property (nonatomic, assign) BOOL autoResize;

@property (nonatomic, readonly) NSInteger actualLineNumber;
@property (nonatomic, readonly) CGSize contentSize;

@end
