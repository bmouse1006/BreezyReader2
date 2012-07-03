//
//  BRSubGridViewController.h
//  BreezyReader2
//
//  Created by 金 津 on 12-2-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JJMediaLib.h"
#import "BRSubGridSource.h"
#import "JJLabel.h"
#import "GRTag.h"

@interface BRSubGridViewController : JJMediaLibController<JJMediaSourceDelegate, UIScrollViewDelegate, UITableViewDelegate>

@property (nonatomic, retain) GRTag* tag;
@property (nonatomic, retain) BRSubGridSource* source;
@property (nonatomic, retain) JJLabel* titleLabel;

-(void)createSource;

@end
