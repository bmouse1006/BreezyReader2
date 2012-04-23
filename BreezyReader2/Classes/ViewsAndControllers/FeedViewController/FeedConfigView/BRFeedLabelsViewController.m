//
//  BRFeedLabelsViewController.m
//  BreezyReader2
//
//  Created by 金 津 on 12-4-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRFeedLabelsViewController.h"
#import "GoogleReaderClient.h"
#import "BRFeedLabelCell.h"
#import "BRFeedLabelNewCell.h"

@interface BRFeedLabelsViewController ()

@property (nonatomic, retain) NSArray* allLabels;

@end

@implementation BRFeedLabelsViewController

@synthesize titleLabel = _titleLabel;
@synthesize allLabels = _allLabels;   
@synthesize topBlack = _topBlack, topWhite = _topWhite;

-(void)dealloc{
    self.titleLabel = nil;
    self.topWhite = nil;
    self.topBlack = nil;
    self.allLabels = nil;
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupLabel:self.titleLabel];
    // Do any additional setup after loading the view from its nib.
    [self.view addSubview:self.topBlack];
    [self.view addSubview:self.topWhite];
    
    self.allLabels = [GoogleReaderClient tagListWithType:BRTagTypeLabel];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.titleLabel.text = NSLocalizedString(@"title_label", nil);
    CGFloat width = self.view.bounds.size.width;
    CGRect frame = CGRectMake(0, 0, width, 0.5);
    self.topBlack.frame = frame;
    frame = CGRectMake(0, 0.5, width, 0.5);
    self.topWhite.frame = frame;
}

-(UIView*)sectionView{
    return self.view;
}

-(CGFloat)heightForHeader{
    return self.view.bounds.size.height;
}

-(NSInteger)numberOfRowsInSection{
    return [self.allLabels count]+1;
}

-(id)cellForRow:(NSInteger)row{
    id cell = nil;
    if (row != [self.allLabels count]){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"BRFeedLabelCell" owner:nil options:nil] objectAtIndex:0];
        GRTag* tag = [self.allLabels objectAtIndex:row];
        ((BRFeedLabelCell*)cell).title = tag.label;
        if ([self.subscription.categories containsObject:tag.ID]){
            ((BRFeedLabelCell*)cell).isChecked = YES;
        }else{
            ((BRFeedLabelCell*)cell).isChecked = NO;
        }
    }else{
        cell = [[[NSBundle mainBundle] loadNibNamed:@"BRFeedLabelNewCell" owner:nil options:nil] objectAtIndex:0];
    }
    
    return cell;
}

-(CGFloat)heightOfRowAtIndex:(NSInteger)index{
    return 40.0f;
}

-(void)setupLabel:(JJLabel*)label{
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:14];
    label.verticalAlignment = JJTextVerticalAlignmentMiddle;
    label.shadowBlur = 3;
    label.shadowColor = [UIColor blackColor];
    label.shadowOffset = CGSizeMake(1, 1);
    label.shadowEnable = NO;
}

@end
