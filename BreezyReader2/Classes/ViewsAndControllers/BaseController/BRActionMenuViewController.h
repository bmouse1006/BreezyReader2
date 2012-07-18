//
//  BRActionMenuViewController.h
//  BreezyReader2
//
//  Created by 金 津 on 12-5-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BRActionMenuViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIView* menu;
-(void)dismiss;
-(void)showMenuInPosition:(CGPoint)position anchorPoint:(CGPoint)anchor;

@end
