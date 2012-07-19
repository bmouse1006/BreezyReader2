//
//  GoogleAPPCommunicator.h
//  BreezyReader
//
//  Created by Jin Jin on 10-5-30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GoogleAuthManager.h"
#import "URLParameterSet.h"
#import "GRFeed.h"
#import "ASIHTTPRequest.h"

#define RECEIVED_DATA @"receivedData"

@protocol GoogleReaderControllerDelegate

-(void)didReceiveErrorWhileRequestingData:(NSError*)error;
-(void)didSuccessFinishedDataReceive:(NSURLResponse*)response;

@end

@interface GoogleReaderController : NSObject

@property  NSString* errorMsg;
@property (unsafe_unretained) id<GoogleReaderControllerDelegate> delegate;

+(id)controller;
//Google Reader interface
//ATOM API, return nil if fail
-(GRFeed*)getFeedForURL:(NSString*)URLString 
				count:(NSNumber*)count 
			startFrom:(NSDate*)date 
			  exclude:(NSString*)excludeString 
		 continuation:(NSString*)continuationStr;

-(GRFeed*)getFeedForLabel:(NSString*)labelName
				  count:(NSNumber*)count 
			  startFrom:(NSDate*)date 
				exclude:(NSString*)excludeString 
		   continuation:(NSString*)continuationStr;

-(GRFeed*)getFeedForStates:(NSString*)state
				   count:(NSNumber*)count 
			   startFrom:(NSDate*)date 
				 exclude:(NSString*)excludeString 
			continuation:(NSString*)continuationStr;

-(GRFeed*)getFeedForID:(NSString*)ID
				 count:(NSNumber*)count
			 startFrom:(NSDate*)date 
			   exclude:(NSString*)excludeString 
		  continuation:(NSString*)continuationStr;

//EDIT API, return nil if fail
//subscribe a feed with title and tag name
-(NSString*)addSubscription:(NSString*)subscription 
				  withTitle:(NSString*)title 
					  toTag:(NSString*)tags;

//unsubscribe a feed
-(NSString*)removeSubscription:(NSString*)subscription;

//mark all as read for a subscription
-(NSString*)markAllAsReadForSubscription:(NSString*)subscription;

//add/remove tag to one subscription
-(NSString*)editSubscription:(NSString*)subscription 
					tagToAdd:(NSString*)tagToAdd 
				 tagToRemove:(NSString*)tagToRemove;

//make a tag public or not
-(NSString*)editTag:(NSString*)tagName 
		publicOrNot:(BOOL)pub;

//disable a tag
-(NSString*)disableTag:(NSString*)tagName;

//change tag/states set for one specific item. Use this to mark item as read/unread
-(NSString*)editItem:(NSString*)itemID 
			  addTag:(NSString*)tagToAdd 
		   removeTag:(NSString*)tagToRemove;

//LIST API, return nil if fail
-(NSDictionary*)allRecommendationFeeds;
-(NSDictionary*)allSubscriptions;
-(NSDictionary*)allTags;
-(NSDictionary*)unreadCount;
//SEARCH API, return nil if nothing being searched
-(NSDictionary*)searchFeeds:(NSString*)keyWord start:(NSInteger)start;
//API


-(id)initWithDelegate:(id<GoogleReaderControllerDelegate>)_delegate;

//get request
-(ASIHTTPRequest*)requestForFeedWithIdentifier:(NSString*)identifer
                                         count:(NSNumber*)count 
                                     startFrom:(NSDate*)date 
                                       exclude:(NSString*)excludeString 
                                  continuation:(NSString*)continuationStr;
-(ASIHTTPRequest*)requestForAllSubscriptions;
-(ASIHTTPRequest*)requestForAllTags;
-(ASIHTTPRequest*)requestForUnreadCount;
-(ASIHTTPRequest*)requestForSearchingArticleWithKeywords:(NSString*)keywords;
-(ASIHTTPRequest*)requestForQueryingContentsWithIDs:(NSArray*)IDs;
-(id)requestWithURL:(NSURL*)baseURL
                      parameters:(URLParameterSet*)parameters 
                         APIType:(NSString*)type;
@end


