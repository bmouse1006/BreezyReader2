//
//  BRImageScrollController.h
//  BreezyReader2
//
//  Created by Jin Jin on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "JJImageScrollController.h"

@interface BRImageScrollController : JJImageScrollController<UIGestureRecognizerDelegate>

@property (nonatomic, retain) IBOutlet UIButton* saveButton;

-(IBAction)saveButtonClicked:(id)sender;

@end
