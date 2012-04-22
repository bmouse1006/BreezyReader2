//
//  GoogleAppConstants.h
//  BreezyReader
//
//  Created by Jin Jin on 10-5-30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
// 

#define SUBSCRIPTIONLISTCHANGED @"SUBSCRIPTIONLISTCHANGED"
#define TAGLISTCHANGED			@"TAGLISTCHANGED"
#define	UNREADCOUNTCHANGED		@"UNREADCOUNTCHANGED"
#define	TAGORSUBCHANGED			@"TAGORSUBCHANGED"
#define LOGINNEEDED				@"LOGINNEEDED"
#define LOGOUTNEEDED            @"LOGOUTNEEDED"
#define LOGINFAILED				@"LOGINFAILED"

#define BEGANSYNCDATA			@"BEGANSYNCDATA"
#define ENDSYNCDATA				@"ENDSYNCDATA"

#define GRERRORHAPPENED			@"NETWORKERRORHAPPENED"

#define GRERROR					@"GRERROR"

#define BEGANFEEDUPDATING		@"BEGANFEEDUPDATING"
#define ENDFEEDUPDATING         @"ENDFEEDUPDATING"

extern NSString* const LOGIN_NOTIN;		
extern NSString* const LOGIN_SUCCESSFUL;	
extern NSString* const LOGIN_FAILED;
extern NSString* const LOGIN_INPROGRESS;	

extern NSString * const COOKIE_DOMAIN;
extern NSString * const COOKIE_SID;
extern NSString * const COOKIE_AUTH;
extern NSString * const COOKIE_PATH;

extern NSString * const URI_LOGIN;
extern NSString * const URI_PREFIX_READER;
extern NSString * const URI_PREFIX_API;
extern NSString * const URI_PREFIX_VIEW;
extern NSString * const URI_PREFIX_FEEDSEARCH;

extern NSString * const ATOM_GET_FEED;

extern NSString * const ATOM_PREFIX_USER;
extern NSString * const ATOM_PREFIX_USER_NUMBER;
extern NSString * const ATOM_PREFIX_LABEL;
extern NSString * const ATOM_PREFIX_STATE_GOOGLE;

extern NSString * const ATOM_STATE_READ;
extern NSString * const ATOM_STATE_UNREAD;
extern NSString * const ATOM_STATE_FRESH;
extern NSString * const ATOM_STATE_READING_LIST;
extern NSString * const ATOM_STATE_BROADCAST;
extern NSString * const ATOM_STATE_STARRED;
extern NSString * const ATOM_SUBSCRIPTIONS;

extern NSString * const API_EDIT_SUBSCRIPTION;
extern NSString * const API_EDIT_TAG1;
extern NSString * const API_EDIT_TAG2;
extern NSString * const API_EDIT_DISABLETAG;
extern NSString * const API_EDIT_MARK_ALL_AS_READ;  

extern NSString * const API_EDIT_ITEM;              

extern NSString * const API_LIST_RELATED;
extern NSString * const API_LIST_RECOMMENDATION;
extern NSString * const API_LIST_PREFERENCE;
extern NSString * const API_LIST_SUBSCRIPTION;
extern NSString * const API_LIST_TAG;
extern NSString * const API_LIST_UNREAD_COUNT;
extern NSString * const API_TOKEN;

extern NSString * const API_SEARCH_ARTICLES;
extern NSString * const API_STREAM_ITEMS_CONTENTS;
extern NSString * const API_STREAM_DETAILS;
extern NSString * const API_STREAM_CONTENTS;

extern NSString * const API_RECOMMENDATION_EDIT;

extern NSString * const URI_QUICKADD;

extern NSString * const OUTPUT_XML;
extern NSString * const OUTPUT_JSON;

extern NSString * const AGENT;

extern NSString * const LOGIN_REQUEST_BODY_STRING;
extern NSString * const LOGIN_TOKEN_STRING;

extern NSString * const ATOM_ARGS_START_TIME;
extern NSString * const ATOM_ARGS_ORDER;
extern NSString * const ATOM_ARGS_EXCLUDE_TARGET;
extern NSString * const ATOM_ARGS_COUNT;
extern NSString * const ATOM_ARGS_CONTINUATION;
extern NSString * const ATOM_ARGS_CLIENT;
extern NSString * const ATOM_ARGS_TIMESTAMP;

extern NSString * const EDIT_ARGS_IMPRESSION;
extern NSString * const EDIT_ARGS_RECOMMENDATION_ACTION;
extern NSString * const EDIT_ARGS_FEED;
extern NSString * const EDIT_ARGS_ITEM;
extern NSString * const EDIT_ARGS_ADD;
extern NSString * const EDIT_ARGS_TITLE;
extern NSString * const EDIT_ARGS_REMOVE;
extern NSString * const EDIT_ARGS_ACTION;
extern NSString * const EDIT_ARGS_TOKEN;
extern NSString * const EDIT_ARGS_PUBLIC;
extern NSString * const EDIT_ARGS_CLIENT;
extern NSString * const EDIT_ARGS_SOURCE;
extern NSString * const EDIT_ARGS_SOURCE_RECOMMENDATION;
extern NSString * const EDIT_ARGS_SOURCE_SEARCH;

extern NSString * const LIST_ARGS_OUTPUT;
extern NSString * const LIST_ARGS_CLIENT;
extern NSString * const LIST_ARGS_TIMESTAMP;
extern NSString * const LIST_ARGS_ALL;

extern NSString * const SEARCH_ARGS_QUERY;
extern NSString * const SEARCH_ARGS_NUMBER;

extern NSString * const CONTENTS_ARGS_ID;
extern NSString * const CONTENTS_ARGS_IT;

extern NSString * const SEARCH_RESULT_SECTION_START;
extern NSString * const SEARCH_RESULT_SECTION_END;

extern NSString * const QUICKADD_ARGS_URL;
extern NSString * const QUICKADD_ARGS_TOKEN;

extern NSString * const ORDER_REVERSE; 
extern NSString * const ACTION_REVERSE; 

extern NSString * const GOOGLE_SCHEME;
extern NSString * const GOOGLE_SCHEME_SSL;

extern NSString * const API_ATOM;
extern NSString * const API_LIST;
extern NSString * const API_EDIT;

extern NSString * const ARGS_CLIENT;
extern NSString * const CLIENT_IDENTIFIER;
//Errro message

extern NSString * const ERROR_NOLOGIN;
extern NSString * const ERROR_NETWORKFAILED;
extern NSString * const ERROR_NEEDRELOGIN;
extern NSString * const ERROR_TOKENERROR;
extern NSString * const ERROR_UNKNOWN	;
