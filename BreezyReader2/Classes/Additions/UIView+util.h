//
//  UIView+ImageRefecltion.h
//  eManual
//
//  Created by  on 11-12-14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (util)

- (UIImage *)reflectedImageRepresentationWithHeight:(NSUInteger)height;
-(UIImage*)snapshot;

CGImageRef AEViewCreateGradientImage (int pixelsWide,
									  int pixelsHigh);

@end
