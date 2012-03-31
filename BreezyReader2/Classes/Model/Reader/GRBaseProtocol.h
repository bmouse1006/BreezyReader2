//
//  BaseGRProtocol.h
//  BreezyReader
//
//  Created by Jin Jin on 10-6-25.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol GRBaseProtocol

@required

-(NSString*)presentationString;//the main string that display in table view
-(NSString*)ID;
//-(NSString*)title;
-(UIImage*)icon;//for Subscription and Tag

@optional

-(NSString*)keyString;
-(NSInteger)unreadCount;//for Subscription and Tag

@end
