//
//  ENNoteComposerController.h
//  SocialAuthTest
//
//  Created by 金 津 on 12-5-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EvernoteSDK.h"

@interface ENNoteComposerController : UITableViewController<UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet UITableViewCell* titleCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* contentCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* urlCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* notebookCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* urlStringCell;

@property (nonatomic, strong) IBOutlet UITextField* titleField;
//@property (nonatomic, retain) IBOutlet UITextView* contentTextView;
@property (nonatomic, strong) IBOutlet UIWebView* contentView;

@property (nonatomic, strong) IBOutlet UIBarButtonItem* sendButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem* cancelButton;

-(IBAction)cancelButtonClicked:(id)sender;
-(IBAction)sendButtonClicked:(id)sender;
-(IBAction)saveURLOnlyChanged:(id)sender;

-(void)setENContent:(NSString*)content;
-(void)setENTitle:(NSString*)title;
-(void)setENURLString:(NSString*)urlString;

@end
