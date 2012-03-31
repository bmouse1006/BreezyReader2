//
//  JJMediaThumbView.h
//  MeetingPlatform
//
//  Created by  on 12-2-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JJMedia.h"

@protocol JJMediaThumbView 

-(void)setObject:(id)obj;
-(void)thumbTouched:(id)sender;
-(void)thumbTouchedDown:(id)sender;
-(void)thumbTouchMoveOut:(id)sender;
-(void)willDisappear:(BOOL)animated;
-(void)didDisappear:(BOOL)animated;
-(void)willAppear:(BOOL)animated;
-(void)didAppear:(BOOL)animated;

@end

@interface JJMediaThumbView : UIControl<JJMediaThumbView>

@property (nonatomic, assign) JJMediaType type;
@property (nonatomic, retain) UIImageView* imageView;
@property (nonatomic, retain) UILabel* captionLabel;

@property (nonatomic, copy) NSString* imageURL;

-(void)clear;



@end
