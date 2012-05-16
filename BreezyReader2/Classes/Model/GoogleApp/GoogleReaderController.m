//
//  GoogleReaderController.m
//  BreezyReader
//
//  Created by Jin Jin on 10-5-30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GoogleReaderController.h"
#import "ASIFormDataRequest.h"

@interface GoogleReaderController ()

-(void)parseLoadedData:(NSData*)data;
-(NSValue*)keyForConnection:(NSURLConnection*)connection;

-(id)readDataFromGoogleReader:(NSString*)urlString 
			   withParameters:(URLParameterSet*)parameters 
					   parser:(SEL)parser 
					  APIType:(NSString*)type;

-(URLParameterSet*)compileParameterSetWithCount:(NSNumber*)count 
									  startFrom:(NSDate*)date 
										exclude:(NSString*)excludeString 
								   continuation:(NSString*)continuationStr;


-(void)notifyError:(NSError*)error withResponse:(NSURLResponse*)response;

-(NSURL*)fullURLFromBaseString:(NSString*)string;

@end

@implementation GoogleReaderController

@synthesize errorMsg = _errorMsg;
@synthesize delegate = _delegate;

+(id)controller{
    return [[[self alloc] init] autorelease];
}
//API here!!

#pragma mark - ATOM API
-(GRFeed*)getFeedForURL:(NSString*)URLString 
				count:(NSNumber*)count 
			startFrom:(NSDate*)date 
			  exclude:(NSString*)excludeString 
		 continuation:(NSString*)continuationStr{
	URLParameterSet* parameterSet = [self compileParameterSetWithCount:count startFrom:date exclude:excludeString continuation:continuationStr];

	NSString* url = [API_STREAM_CONTENTS stringByAppendingString:ATOM_GET_FEED];
	url = [url stringByAppendingString:URLString];
    return [self readDataFromGoogleReader:url
                           withParameters:parameterSet
                                   parser:@selector(ATOMParser:) 
                                  APIType:API_ATOM];
}

-(GRFeed*)getFeedForLabel:(NSString*)labelName				
				  count:(NSNumber*)count 
			  startFrom:(NSDate*)date 
				exclude:(NSString*)excludeString 
		   continuation:(NSString*)continuationStr{
	URLParameterSet* parameterSet = [self compileParameterSetWithCount:count startFrom:date exclude:excludeString continuation:continuationStr];
	
	NSString* url = [API_STREAM_CONTENTS stringByAppendingString:ATOM_PREFIX_LABEL];
	url = [url stringByAppendingString:labelName];
    return [self readDataFromGoogleReader:url
                           withParameters:parameterSet
                                   parser:@selector(ATOMParser:) 
                                  APIType:API_ATOM];
}

-(GRFeed*)getFeedForStates:(NSString*)state
				   count:(NSNumber*)count 
			   startFrom:(NSDate*)date 
				 exclude:(NSString*)excludeString 
			continuation:(NSString*)continuationStr{
	URLParameterSet* parameterSet = [self compileParameterSetWithCount:count startFrom:date exclude:excludeString continuation:continuationStr];
	
	NSString* url = [API_STREAM_CONTENTS stringByAppendingString:state];
    return [self readDataFromGoogleReader:url
                           withParameters:parameterSet
                                   parser:@selector(ATOMParser:) 
                                  APIType:API_ATOM];
}

-(GRFeed*)getFeedForID:(NSString*)ID
				 count:(NSNumber*)count
			 startFrom:(NSDate*)date 
			   exclude:(NSString*)excludeString 
		  continuation:(NSString*)continuationStr{
	
	URLParameterSet* parameterSet = [self compileParameterSetWithCount:count startFrom:date exclude:excludeString continuation:continuationStr];
	
	NSString* url = [API_STREAM_CONTENTS stringByAppendingString:ID];
    return [self readDataFromGoogleReader:url
                           withParameters:parameterSet
                                   parser:@selector(ATOMParser:) 
                                  APIType:API_ATOM];
	
}

#pragma mark - LIST API
//LIST API, return nil if fail
-(NSDictionary*)allRecommendationFeeds{
	NSString* url = [URI_PREFIX_API stringByAppendingString:API_LIST_RECOMMENDATION];
	URLParameterSet* paramSet = [[[URLParameterSet alloc] init] autorelease];
	[paramSet setParameterForKey:ATOM_ARGS_COUNT withValue:@"99999"];
	[paramSet setParameterForKey:LIST_ARGS_OUTPUT withValue:OUTPUT_JSON];
    return [self readDataFromGoogleReader:url
                           withParameters:paramSet
                                   parser:@selector(JSONParser:) 
                                  APIType:API_LIST];
}

-(NSDictionary*)allSubscriptions{
	NSString* url = [URI_PREFIX_API stringByAppendingString:API_LIST_SUBSCRIPTION];
	URLParameterSet* paramSet = [[[URLParameterSet alloc] init] autorelease];
	[paramSet setParameterForKey:LIST_ARGS_OUTPUT withValue:OUTPUT_JSON];
    return [self readDataFromGoogleReader:url
                           withParameters:paramSet
                                   parser:@selector(JSONParser:) 
                                  APIType:API_LIST];
}

//return all tags
-(NSDictionary*)allTags{
	NSString* url = [URI_PREFIX_API stringByAppendingString:API_LIST_TAG];
	URLParameterSet* paramSet = [[[URLParameterSet alloc] init] autorelease];
	[paramSet setParameterForKey:LIST_ARGS_OUTPUT withValue:OUTPUT_JSON];
    return [self readDataFromGoogleReader:url
                           withParameters:paramSet
                                   parser:@selector(JSONParser:) 
                                  APIType:API_LIST];
}

//return unread cound for all subscription and tags
-(NSDictionary*)unreadCount{
	NSString* url = [URI_PREFIX_API stringByAppendingString:API_LIST_UNREAD_COUNT];
	URLParameterSet* paramSet = [[[URLParameterSet alloc] init] autorelease];
	[paramSet setParameterForKey:@"output" withValue:@"json"];
    return [self readDataFromGoogleReader:url
                           withParameters:paramSet
                                   parser:@selector(JSONParser:)
                                  APIType:API_LIST];
}

//return result of search by keywords and start point
-(NSDictionary*)searchFeeds:(NSString*)keyWord start:(NSInteger)start{
    URLParameterSet* paramSet = [[[URLParameterSet alloc] init] autorelease];
    [paramSet setParameterForKey:@"q" withValue:keyWord];
    [paramSet setParameterForKey:@"start" withValue:[NSString stringWithFormat:@"%d", start]];
    [paramSet setParameterForKey:@"client" withValue:@"scroll"];
    return [self readDataFromGoogleReader:URI_PREFIX_FEEDSEARCH
											withParameters:paramSet
													parser:@selector(SEARCHParser:) 
												   APIType:API_LIST];
}

//add a new subscription to Google reader
//return "ok" for success, return "" or nil for fail
-(NSString*)addSubscription:(NSString*)subscription 
				  withTitle:(NSString*)title 
					  toTag:(NSString*)tag{
	//get complete feed URI in Google Reader
	NSString* url = [URI_PREFIX_API stringByAppendingString:API_EDIT_SUBSCRIPTION];
	NSString* feedName = subscription;
	//Prepare parameters
	URLParameterSet* paramSet = [[[URLParameterSet alloc] init] autorelease];
	if (feedName){
		[paramSet setParameterForKey:EDIT_ARGS_FEED withValue:feedName];//add feed URI
	}
	if (title){
		[paramSet setParameterForKey:EDIT_ARGS_TITLE withValue:title];//add feed title
	}
	if (tag){
		[paramSet setParameterForKey:EDIT_ARGS_ADD withValue:tag];//add tag name
	}

	[paramSet setParameterForKey:EDIT_ARGS_ACTION withValue:@"subscribe"];//add API action. Here is 'subscribe'
	
    return [self readDataFromGoogleReader:url
                           withParameters:paramSet
                                   parser:@selector(EDITParser:) 
                                  APIType:API_EDIT];
}

//mark all as read for a subscription
-(NSString*)markAllAsReadForSubscription:(NSString*)subscription{
	//get complete feed URI in Google Reader
	NSString* url = [URI_PREFIX_API stringByAppendingString:API_EDIT_MARK_ALL_AS_READ];
	//Prepare parameters
	URLParameterSet* paramSet = [[[URLParameterSet alloc] init] autorelease];
	
	[paramSet setParameterForKey:EDIT_ARGS_FEED withValue:subscription];//add feed URI
//	[paramSet setParameterForKey:EDIT_ARGS_ACTION withValue:@"unsubscribe"];//add API action. Here is 'unsubscribe'
	
    return [self readDataFromGoogleReader:url
                           withParameters:paramSet
                                   parser:@selector(EDITParser:) 
                                  APIType:API_EDIT];
	
}

//remove a subscription from Google Reader
//return "ok" for successs, "" or nil for fail
-(NSString*)removeSubscription:(NSString*)subscription{
	//get complete feed URI in Google Reader
	NSString* url = [URI_PREFIX_API stringByAppendingString:API_EDIT_SUBSCRIPTION];
	//Prepare parameters
	URLParameterSet* paramSet = [[[URLParameterSet alloc] init] autorelease];
	[paramSet setParameterForKey:EDIT_ARGS_FEED withValue:subscription];//add feed URI
	[paramSet setParameterForKey:EDIT_ARGS_ACTION withValue:@"unsubscribe"];//add API action. Here is 'unsubscribe'
	
	return [self readDataFromGoogleReader:url
                           withParameters:paramSet
                                   parser:@selector(EDITParser:) 
                                  APIType:API_EDIT];

}

//edit tag name for one subsctiption, add and remove
//return "ok" for successs, "" or nil for fail
-(NSString*)editSubscription:(NSString*)subscription 
					tagToAdd:(NSString*)tagToAdd 
				 tagToRemove:(NSString*)tagToRemove{
	//get complete feed URI in Google Reader
	NSString* url = [URI_PREFIX_API stringByAppendingString:API_EDIT_SUBSCRIPTION];
	//Prepare parameters
	URLParameterSet* paramSet = [[[URLParameterSet alloc] init] autorelease];
	[paramSet setParameterForKey:EDIT_ARGS_FEED withValue:subscription];//add feed URI
	if (tagToAdd != nil)
		[paramSet setParameterForKey:EDIT_ARGS_ADD withValue:tagToAdd];//tag name to add
	if (tagToRemove != nil)
		[paramSet setParameterForKey:EDIT_ARGS_REMOVE withValue:tagToRemove];//tag name to remove
	[paramSet setParameterForKey:EDIT_ARGS_ACTION withValue:@"edit"];//add API action. Here is 'edit'
	
    return [self readDataFromGoogleReader:url
                           withParameters:paramSet
                                   parser:@selector(EDITParser:) 
                                  APIType:API_EDIT];
	
}

//make this tag public
-(NSString*)editTag:(NSString*)tagName 
		publicOrNot:(BOOL)pub{
	//get complete feed URI in Google Reader
	NSString* url = [URI_PREFIX_API stringByAppendingString:API_EDIT_TAG1];
	//Prepare parameters
	URLParameterSet* paramSet = [[[URLParameterSet alloc] init] autorelease];
	[paramSet setParameterForKey:EDIT_ARGS_FEED withValue:tagName];//add feed URI
	
	NSString* pubValue = nil;
	if (pub)
		pubValue = @"true";
	else {
		pubValue = @"false";
	}

	[paramSet setParameterForKey:EDIT_ARGS_PUBLIC withValue:pubValue];//make it public or not
	
	return [self readDataFromGoogleReader:url
                           withParameters:paramSet
                                   parser:@selector(EDITParser:)
                                  APIType:API_EDIT];
}

//to disable(remove) a tag
-(NSString*)disableTag:(NSString*)tagName{
	//get complete feed URI in Google Reader
	NSString* url = [URI_PREFIX_API stringByAppendingString:API_EDIT_DISABLETAG];
	//Prepare parameters
	URLParameterSet* paramSet = [[[URLParameterSet alloc] init] autorelease];
	[paramSet setParameterForKey:EDIT_ARGS_FEED withValue:tagName];//add feed URI
	[paramSet setParameterForKey:EDIT_ARGS_ACTION withValue:@"disable-tags"];//add API action. Here is 'unsubscribe'
	
    return [self readDataFromGoogleReader:url
                           withParameters:paramSet
                                   parser:@selector(EDITParser:) 
                                  APIType:API_EDIT];
	
}

//add and/or remove tags for one item
-(NSString*)editItem:(NSString*)itemID 
			  addTag:(NSString*)tagToAdd 
		   removeTag:(NSString*)tagToRemove{
	//get complete feed URI in Google Reader
	NSString* url = [URI_PREFIX_API stringByAppendingString:API_EDIT_TAG2];
	//Prepare parameters
	URLParameterSet* paramSet = [[[URLParameterSet alloc] init] autorelease];
	[paramSet setParameterForKey:EDIT_ARGS_ITEM withValue:itemID];//add feed URI
	if (tagToAdd != nil)
		[paramSet setParameterForKey:EDIT_ARGS_ADD withValue:tagToAdd];//tag name to add
	if (tagToRemove != nil)
		[paramSet setParameterForKey:EDIT_ARGS_REMOVE withValue:tagToRemove];//tag name to remove
	[paramSet setParameterForKey:EDIT_ARGS_ACTION withValue:@"edit"];//add API action. Here is 'edit'
	
	return [self readDataFromGoogleReader:url
                           withParameters:paramSet
                                   parser:@selector(EDITParser:) 
                                  APIType:API_EDIT];
}


//init and alloc
-(id)initWithDelegate:(id<GoogleReaderControllerDelegate>)delegate{
	if (self = [super init]){
		NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
		[dictionary release];
		self.delegate = delegate;
	}
	return self;
}

-(void)dealloc{
    self.errorMsg = nil;
	[super dealloc];
}

/////Private method

-(void)parseLoadedData:(NSData*)data{
	NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	DebugLog(@"received data is: %@", str);
	[str release];
}

-(NSValue*)keyForConnection:(NSURLConnection*)connection{
	return [NSValue valueWithNonretainedObject:connection];
}

//the most important communicate method
-(id)readDataFromGoogleReader:(NSString*)urlString 
			   withParameters:(URLParameterSet*)parameters 
					   parser:(SEL)_parser
					  APIType:(NSString*)type{
	GoogleAuthManager* gaManager = [GoogleAuthManager shared];
	NSMutableURLRequest* request = [gaManager URLRequestFromString:urlString];
    
    if (request == nil){
        //error happened
        self.errorMsg = [gaManager.error localizedDescription];
        [self.delegate didReceiveErrorWhileRequestingData:gaManager.error];
        return nil;
    }
    
	id result = nil;
	
	int retry = 0;
	do{
			
		if ([type isEqualToString:API_EDIT]){
//			if (gaManager.token == nil){
				//token is empty and get token failed, then return nil
                NSError* error = nil;
//                [gaManager getValidToken:&error];
                if (!error){
                    [self.delegate didSuccessFinishedDataReceive:nil];
                }else {
                    self.errorMsg = ERROR_NETWORKFAILED;
                    [self.delegate didReceiveErrorWhileRequestingData:error];
                    return nil;
                }
//			}
//			[parameters setParameterForKey:EDIT_ARGS_TOKEN withValue:gaManager.token];
			[request setHTTPMethod:@"POST"];//POST method for list api
			[request setHTTPBody:[[parameters parameterString] dataUsingEncoding:NSUTF8StringEncoding]];
			URLParameterSet* additionalParameters = [[URLParameterSet alloc] init];
			
			if (!retry){
				[additionalParameters setParameterForKey:EDIT_ARGS_CLIENT withValue:CLIENT_IDENTIFIER];
				[additionalParameters setParameterForKey:EDIT_ARGS_SOURCE withValue:EDIT_ARGS_SOURCE_RECOMMENDATION];
				
				NSString* temp = [request.URL absoluteString];
				temp = [temp stringByAppendingString:@"?"];
				temp = [temp stringByAppendingString:[additionalParameters parameterString]];
				[request setURL:[NSURL URLWithString:temp]];
				 
				[additionalParameters release];
			}
		}else{
			[request setHTTPMethod:@"GET"];//GET method for others
			if (!retry){
				NSString* temp = [request.URL absoluteString];
				if (parameters){
					temp = [temp stringByAppendingString:@"?"];
					temp = [temp stringByAppendingString:[parameters parameterString]];
				}
				[request setURL:[NSURL URLWithString:temp]];
			}
		}
		
		DebugLog(@"url str is %@", [request.URL absoluteString]);
		
		UIApplication* app = [UIApplication sharedApplication]; 
		app.networkActivityIndicatorVisible = YES; // start network activity indicator
		
		NSError* error = nil;
		NSURLResponse* response = nil;
		
        request.timeoutInterval = 20;
        [[GoogleAuthManager shared] authRequest:request];
        DebugLog(@"request is %@", request);
        DebugLog(@"header is %@", [request allHTTPHeaderFields]);
		NSData* returningData = [NSURLConnection sendSynchronousRequest:request
													  returningResponse:&response 
																  error:&error];
		
		app.networkActivityIndicatorVisible = NO; // stop network activity indicator
		
		if (error){
            DebugLog(@"%@", [error localizedDescription]);
			[self.delegate didReceiveErrorWhileRequestingData:error];
			return nil;
		}
		[self.delegate didSuccessFinishedDataReceive:response];
		result = [self performSelector:_parser withObject:returningData];
		[[result retain] autorelease];
		if (result != nil){
			return result;
		}
		
		if ([type isEqual:API_EDIT]){
			retry++;
			//重新获取token
//			[self getValidToken];
		}else {
			self.errorMsg = ERROR_NOLOGIN;
			return nil;
		}
	}while(retry<=1);

	self.errorMsg = ERROR_UNKNOWN;
	return nil;
}


-(URLParameterSet*)compileParameterSetWithCount:(NSNumber*)count 
									  startFrom:(NSDate*)date 
										exclude:(NSString*)excludeString 
								   continuation:(NSString*)continuationStr{
	URLParameterSet* parameterSet = nil;
	
	if (count||date||excludeString||continuationStr){
		parameterSet = [[[URLParameterSet alloc] init] autorelease];
		if (count)
			[parameterSet setParameterForKey:ATOM_ARGS_COUNT withValue:[count stringValue]];
		if (date)
			[parameterSet setParameterForKey:ATOM_ARGS_START_TIME withValue:[NSString stringWithFormat:@"%d", [date timeIntervalSince1970]]];
		if (excludeString)
			[parameterSet setParameterForKey:ATOM_ARGS_EXCLUDE_TARGET withValue:excludeString];
		if (continuationStr)
			[parameterSet setParameterForKey:ATOM_ARGS_CONTINUATION withValue:continuationStr];
	}
	
	return parameterSet;
}


-(void)notifyError:(NSError*)error withResponse:(NSURLResponse*)response{
	dispatch_sync(dispatch_get_main_queue(), ^{
       	[[NSNotificationCenter defaultCenter] postNotificationName:ERROR_UNKNOWN object:nil userInfo:nil]; 
    });
	
	NSArray* keys = [error.userInfo allKeys];
	for (NSString* key in keys){
		DebugLog(@"error key: %@", key);
		DebugLog(@"error value: %@", [error.userInfo objectForKey:key]);
	}
	
}

-(id)requestWithURL:(NSURL*)baseURL
                             parameters:(URLParameterSet*)parameters 
                                APIType:(NSString*)type{
    ASIHTTPRequest* request = nil;
    if ([type isEqualToString:API_EDIT]){
        request = [ASIFormDataRequest requestWithURL:baseURL];
//        if (gaManager.token == nil){
//            //token is empty and get token failed, then return nil
//            NSError* error = nil;
//            [gaManager getValidToken:&error];
//            if (!error){
//                [self.delegate didSuccessFinishedDataReceive:nil];
//            }else {
//                self.errorMsg = ERROR_NETWORKFAILED;
//                [self.delegate didReceiveErrorWhileRequestingData:error];
//                return nil;
//            }
//        }
//        [parameters setParameterForKey:EDIT_ARGS_TOKEN withValue:gaManager.token];
        request.requestMethod = @"POST";//POST method for list api
        [request appendPostData:[[parameters parameterString] dataUsingEncoding:NSUTF8StringEncoding]];
        URLParameterSet* additionalParameters = [[URLParameterSet alloc] init];
        
        [additionalParameters setParameterForKey:EDIT_ARGS_CLIENT withValue:CLIENT_IDENTIFIER];
        [additionalParameters setParameterForKey:EDIT_ARGS_SOURCE withValue:EDIT_ARGS_SOURCE_RECOMMENDATION];
        
        NSString* temp = [request.url absoluteString];
        temp = [temp stringByAppendingString:@"?"];
        temp = [temp stringByAppendingString:[additionalParameters parameterString]];
        [request setURL:[NSURL URLWithString:temp]];
        
        [additionalParameters release];
        
    }else{
        request = [ASIHTTPRequest requestWithURL:baseURL];
        request.requestMethod = @"GET";//GET method for others
        NSString* temp = [request.url absoluteString];
        if (parameters){
            temp = [temp stringByAppendingString:@"?"];
            temp = [temp stringByAppendingString:[parameters parameterString]];
        }
        [request setURL:[NSURL URLWithString:temp]];
    }
    
    request.cachePolicy = ASIOnlyLoadIfNotCachedCachePolicy;
    request.cacheStoragePolicy = ASICacheForSessionDurationCacheStoragePolicy;
    
    DebugLog(@"request string is %@", [request.url absoluteString]);
    
    return request;
}

-(ASIHTTPRequest*)requestForFeedWithIdentifier:(NSString*)identifer
                                        count:(NSNumber*)count 
                                    startFrom:(NSDate*)date 
                                      exclude:(NSString*)excludeString 
                                 continuation:(NSString*)continuationStr{
	
	URLParameterSet* parameterSet = [self compileParameterSetWithCount:count startFrom:date exclude:excludeString continuation:continuationStr];
    if (identifer.length == 0){
        return nil;
    }
	NSString* url = [API_STREAM_CONTENTS stringByAppendingString:identifer];
    ASIHTTPRequest* request = [self requestWithURL:[self fullURLFromBaseString:url] parameters:parameterSet APIType:API_ATOM];
    request.cachePolicy = ASIUseDefaultCachePolicy;
    request.cacheStoragePolicy = ASICacheForSessionDurationCacheStoragePolicy;
    return request;
}

-(ASIHTTPRequest*)requestForAllSubscriptions{
    NSString* url = [URI_PREFIX_API stringByAppendingString:API_LIST_SUBSCRIPTION];
    URLParameterSet* paramSet = [[[URLParameterSet alloc] init] autorelease];
	[paramSet setParameterForKey:LIST_ARGS_OUTPUT withValue:OUTPUT_JSON];
    return [self requestWithURL:[self fullURLFromBaseString:url] parameters:paramSet APIType:API_LIST];
}

-(ASIHTTPRequest*)requestForAllTags{
    NSString* url = [URI_PREFIX_API stringByAppendingString:API_LIST_TAG];
	URLParameterSet* paramSet = [[[URLParameterSet alloc] init] autorelease];
	[paramSet setParameterForKey:LIST_ARGS_OUTPUT withValue:OUTPUT_JSON];
    return [self requestWithURL:[self fullURLFromBaseString:url] parameters:paramSet APIType:API_LIST];
}

-(ASIHTTPRequest*)requestForUnreadCount{
    NSString* url = [URI_PREFIX_API stringByAppendingString:API_LIST_UNREAD_COUNT];
	URLParameterSet* paramSet = [[[URLParameterSet alloc] init] autorelease];
	[paramSet setParameterForKey:LIST_ARGS_OUTPUT withValue:OUTPUT_JSON];
    return [self requestWithURL:[self fullURLFromBaseString:url] parameters:paramSet APIType:API_LIST];
}

-(ASIHTTPRequest*)requestForSearchingArticleWithKeywords:(NSString*)keywords{
    URLParameterSet* paramSet = [[[URLParameterSet alloc] init] autorelease];
    [paramSet setParameterForKey:LIST_ARGS_OUTPUT withValue:OUTPUT_JSON];
    [paramSet setParameterForKey:SEARCH_ARGS_NUMBER withValue:[NSNumber numberWithInt:100]];
    [paramSet setParameterForKey:SEARCH_ARGS_QUERY withValue:keywords];
    return [self requestWithURL:[self fullURLFromBaseString:API_SEARCH_ARTICLES] parameters:paramSet APIType:API_LIST];
}

-(ASIHTTPRequest*)requestForQueryingContentsWithIDs:(NSArray*)IDs{
    ASIFormDataRequest* request = [self requestWithURL:[self fullURLFromBaseString:API_STREAM_ITEMS_CONTENTS] parameters:nil APIType:API_EDIT];
    for (NSDictionary* ID in IDs){
        [request addPostValue:[ID objectForKey:@"id"] forKey:CONTENTS_ARGS_ID];
        [request addPostValue:@"0" forKey:CONTENTS_ARGS_IT];
    }
//    [request addPostValue:[[GoogleAuthManager shared] token] forKey:EDIT_ARGS_TOKEN];
    
    return request;
}

-(NSURL*)fullURLFromBaseString:(NSString*)string{
    //encode URL string
	NSString* googleScheme = nil;
	BOOL enableSSL = YES;
	if (enableSSL){
		googleScheme = GOOGLE_SCHEME_SSL;
	}else {
		googleScheme = GOOGLE_SCHEME;
	}
    
	NSString* encodedURLString = [googleScheme stringByAppendingString:[string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	DebugLog(@"encoded URL String is %@", encodedURLString);
	//构造request
	return [NSURL URLWithString:encodedURLString];
}

@end
						
						
