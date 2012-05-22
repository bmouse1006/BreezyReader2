//
//  BaseMessageView.h
//  eManual
//
//  Created by  on 12-1-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseView.h"

@interface BaseMessageView : BaseView

@property (nonatomic, copy, setter = setMessage:) NSString* message;

@property (nonatomic, retain) IBOutlet UITextView* textView;
@property (nonatomic, retain) IBOutlet UIView* container;

@end
