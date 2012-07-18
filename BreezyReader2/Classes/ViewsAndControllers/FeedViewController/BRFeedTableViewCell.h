//
//  BRFeedTableViewCell.h
//  BreezyReader2
//
//  Created by 金 津 on 12-3-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GRItem.h"
#import "JJImageView.h"
#import "JJLabel.h"

@interface BRFeedTableViewCell : UITableViewCell

@property (nonatomic, strong) GRItem* item;
@property (nonatomic, strong) IBOutlet JJImageView* urlImageView;

@property (nonatomic, strong) IBOutlet UIView* bottomSeperateLine;
@property (nonatomic, strong) IBOutlet JJLabel* titleLabel;
@property (nonatomic, strong) IBOutlet JJLabel* previewLabel;
@property (nonatomic, strong) IBOutlet JJLabel* timeLabel;
@property (nonatomic, strong) IBOutlet JJLabel* authorLabel;

@property (nonatomic, strong) IBOutlet UIView* container;

@property (nonatomic, strong) IBOutlet UIButton* starButton;
@property (nonatomic, strong) IBOutlet UIButton* unstarButton;

@property (nonatomic, strong) IBOutlet UIView* buttonContainer;

@property (nonatomic, strong) NSArray* imageList;

@property (nonatomic, assign) BOOL showSource;

-(IBAction)starButtonClicked:(id)sender;
-(IBAction)unstarButtonClicked:(id)sender;

-(void)updateStarButton;
-(void)updateReadColor;

@end
