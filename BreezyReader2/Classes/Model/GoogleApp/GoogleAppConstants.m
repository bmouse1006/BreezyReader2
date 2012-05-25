//
//  GoogleAppConstants.m
//  BreezyReader
//
//  Created by Jin Jin on 10-6-5.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GoogleAppConstants.h"

NSString* const LOGIN_NOTIN					= @"0";		
NSString* const LOGIN_SUCCESSFUL			= @"1";	
NSString* const LOGIN_FAILED				= @"2";
NSString* const LOGIN_INPROGRESS			= @"3";

NSString * const CLIENT_IDENTIFIER			= @"BREEZYREADER-2.0.0";

NSString * const GOOGLE_SCHEME				= @"http://www.google.com/";
NSString * const GOOGLE_SCHEME_SSL			= @"https://www.google.comm/";

NSString * const COOKIE_DOMAIN				= @".google.com";
NSString * const COOKIE_SID					= @"SID";
NSString * const COOKIE_AUTH				= @"Auth";
NSString * const COOKIE_PATH				= @"/";

NSString * const URI_LOGIN					= @"https://www.google.com/accounts/ClientLogin";

NSString * const URI_PREFIX_READER			= @"reader/";
//NSString * const API_STREAM_CONTENTS			= @"reader/atom/";
NSString * const URI_PREFIX_API			    = @"reader/api/0/";
NSString * const URI_PREFIX_VIEW			= @"reader/view/";
NSString * const URI_PREFIX_FEEDSEARCH      = @"reader/directory/search";

NSString * const ATOM_GET_FEED				= @"feed/";

NSString * const ATOM_PREFIX_USER			= @"user/-/";
NSString * const ATOM_PREFIX_USER_NUMBER	= @"user/00000000000000000000/";
NSString * const ATOM_PREFIX_LABEL			= @"user/-/label/";
NSString * const ATOM_PREFIX_STATE_GOOGLE	= @"user/-/state/com.google/";

NSString * const ATOM_STATE_READ			= @"read";
NSString * const ATOM_STATE_UNREAD			= @"kept-unread";
NSString * const ATOM_STATE_FRESH			= @"fresh";
NSString * const ATOM_STATE_READING_LIST	= @"reading-list";
NSString * const ATOM_STATE_BROADCAST		= @"broadcast";
NSString * const ATOM_STATE_STARRED			= @"starred";
NSString * const ATOM_SUBSCRIPTIONS			= @"subscriptions";

NSString * const API_EDIT_SUBSCRIPTION		= @"subscription/edit";
NSString * const API_EDIT_TAG1				= @"tag/edit";
NSString * const API_EDIT_TAG2				= @"edit-tag";
NSString * const API_EDIT_DISABLETAG		= @"disable-tag";

NSString * const API_EDIT_ITEM              = @"item/edit";

NSString * const API_EDIT_MARK_ALL_AS_READ  = @"mark-all-as-read";

NSString * const API_LIST_RELATED           = @"related/list";
NSString * const API_LIST_RECOMMENDATION	= @"recommendation/list";
NSString * const API_LIST_PREFERENCE		= @"preference/list";
NSString * const API_LIST_SUBSCRIPTION		= @"subscription/list";
NSString * const API_LIST_TAG				= @"tag/list";
NSString * const API_LIST_UNREAD_COUNT		= @"unread-count";
NSString * const API_TOKEN					= @"token";

NSString * const API_SEARCH_ARTICLES        = @"reader/api/0/search/items/ids";
NSString * const API_STREAM_ITEMS_CONTENTS  = @"reader/api/0/stream/items/contents";
NSString * const API_STREAM_CONTENTS        = @"reader/api/0/stream/contents/";
NSString * const API_STREAM_ITEMS           = @"reader/api/0/stream/items/";
NSString * const API_STREAM_DETAILS         = @"reader/api/0/stream/details";

NSString * const API_RECOMMENDATION_EDIT  = @"reader/api/0/recommendation/edit";

NSString * const URI_QUICKADD				= @"http://www.google.com/reader/quickadd";

NSString * const OUTPUT_XML					= @"xml";
NSString * const OUTPUT_JSON				= @"json";

NSString * const AGENT						= @"BreezyReader-1.0";

NSString * const LOGIN_REQUEST_BODY_STRING	= @"accountType=HOSTED_OR_GOOGLE&Email=%@&Passwd=%@"
												"&service=reader&source=BREEZYREADER-1.0.0&continue=http://www.google.com";
NSString * const LOGIN_TOKEN_STRING			= @"&logintoken=%@@logincaptcha=%@";

NSString * const ATOM_ARGS_START_TIME		= @"ot";
NSString * const ATOM_ARGS_ORDER			= @"r";
NSString * const ATOM_ARGS_EXCLUDE_TARGET	= @"xt";
NSString * const ATOM_ARGS_COUNT			= @"n";
NSString * const ATOM_ARGS_CONTINUATION		= @"c";
NSString * const ATOM_ARGS_CLIENT			= @"client";
NSString * const ATOM_ARGS_TIMESTAMP		= @"ck";

NSString * const EDIT_ARGS_IMPRESSION		= @"impression";
NSString * const EDIT_ARGS_RECOMMENDATION_ACTION = @"action";
NSString * const EDIT_ARGS_FEED				= @"s";
NSString * const EDIT_ARGS_ITEM			    = @"i";
NSString * const EDIT_ARGS_ADD				= @"a";		
NSString * const EDIT_ARGS_TITLE			= @"t";
NSString * const EDIT_ARGS_REMOVE			= @"r";
NSString * const EDIT_ARGS_ACTION			= @"ac";
NSString * const EDIT_ARGS_TOKEN			= @"T";
NSString * const EDIT_ARGS_PUBLIC			= @"pub";
NSString * const EDIT_ARGS_CLIENT			= @"client";
NSString * const EDIT_ARGS_SOURCE			= @"source";
NSString * const EDIT_ARGS_SOURCE_RECOMMENDATION = @"RECOMMENDATION";
NSString * const EDIT_ARGS_SOURCE_SEARCH	= @"SEARCH";

NSString * const LIST_ARGS_OUTPUT			= @"output";
NSString * const LIST_ARGS_CLIENT			= @"client";
NSString * const LIST_ARGS_TIMESTAMP		= @"ck";
NSString * const LIST_ARGS_ALL				= @"all";

NSString * const SEARCH_ARGS_QUERY          = @"q";
NSString * const SEARCH_ARGS_NUMBER         = @"num";

NSString * const CONTENTS_ARGS_ID           = @"i";
NSString * const CONTENTS_ARGS_IT           = @"it";

NSString * const SEARCH_RESULT_SECTION_START = @"<script type=\"text/javascript\">var _DIRECTORY_SEARCH_DATA = ";
NSString * const SEARCH_RESULT_SECTION_END  = @"</script>";

NSString * const ARGS_CLIENT				= @"client";

NSString * const QUICKADD_ARGS_URL			= @"quickadd";
NSString * const QUICKADD_ARGS_TOKEN		= @"T";

NSString * const ORDER_REVERSE				= @"o";
NSString * const ACTION_REVERSE				= @"o";

NSString * const API_ATOM					= @"API_ATOM";
NSString * const API_LIST					= @"API_LIST";
NSString * const API_EDIT					= @"API_EDIT";

//error message
NSString * const ERROR_NOLOGIN				= @"ERROR_NOLOGIN";
NSString * const ERROR_NETWORKFAILED		= @"ERROR_NETWORKFAILED";
NSString * const ERROR_NEEDRELOGIN			= @"ERROR_NEEDRELOGIN";
NSString * const ERROR_TOKENERROR			= @"ERROR_TOKENERROR";
NSString * const ERROR_UNKNOWN				= @"ERROR_UNKNOWN";
