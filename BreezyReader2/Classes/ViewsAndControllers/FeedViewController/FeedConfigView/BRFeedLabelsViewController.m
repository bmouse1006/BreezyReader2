//
//  BRFeedLabelsViewController.m
//  BreezyReader2
//
//  Created by 金 津 on 12-4-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRFeedLabelsViewController.h"
#import "GoogleReaderClient.h"

@interface BRFeedLabelsViewController ()

@property (nonatomic, retain) NSArray* tags;

@end

@implementation BRFeedLabelsViewController

@synthesize subscription = _subscription;
@synthesize titleLabel = _titleLabel;
@synthesize tags = _tags;   
@synthesize topBlack = _topBlack, topWhite = _topWhite, bottomBlack = _bottomBlack, bottomWhite = _bottomWhite;

-(void)dealloc{
    self.titleLabel = nil;
    self.topWhite = nil;
    self.topBlack = nil;
    self.bottomBlack = nil;
    self.bottomWhite = nil;
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

-(void)setSubscription:(GRSubscription *)subscription{
    if (_subscription != subscription){
        [_subscription release];
        _subscription = [subscription retain];
        NSArray* keysForLabels = [subscription keysForLabels];
        NSMutableArray* tags = [NSMutableArray array];
        [keysForLabels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop){
            [tags addObject:[GoogleReaderClient tagWithID:obj]];
        }];
        
        self.tags = tags;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupLabel:self.titleLabel];
//    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.text = NSLocalizedString(@"title_label", nil);
    // Do any additional setup after loading the view from its nib.
    [self.view addSubview:self.topBlack];
    [self.view addSubview:self.topWhite];
    [self.view addSubview:self.bottomBlack];
    [self.view addSubview:self.bottomWhite];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    CGFloat inset = 5.0;
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    CGRect frame = CGRectMake(0, 0, width, 0.5);
    self.topBlack.frame = frame;
    frame = CGRectMake(0, 0.5, width, 0.5);
    self.topWhite.frame = frame;
    frame = CGRectMake(inset, height-0.5, width - inset*2, 0.5);
    self.bottomBlack.frame = frame;
    frame = CGRectMake(inset, height, width - inset*2, 0.5);
    self.bottomWhite.frame = frame;
}

-(UIView*)sectionView{
    return self.view;
}

-(CGFloat)heightForHeader{
    return self.view.bounds.size.height;
}

-(NSInteger)numberOfRowsInSection{
    return [self.tags count];
}

-(id)cellForRow:(NSInteger)row{
}

-(CGFloat)heightOfRowAtIndex:(NSInteger)index{
    return 40.0f;
}

-(void)setupLabel:(JJLabel*)label{
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:13];
    label.verticalAlignment = JJTextVerticalAlignmentMiddle;
    label.shadowBlur = 3;
    label.shadowColor = [UIColor blackColor];
    label.shadowOffset = CGSizeMake(1, 1);
    label.shadowEnable = NO;
}

@end
