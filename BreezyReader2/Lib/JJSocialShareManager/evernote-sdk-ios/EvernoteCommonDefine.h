//
//  EvernoteCommonDefine.h
//  SocialAuthTest
//
//  Created by Jin Jin on 12-5-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#define EvernoteLocalizedString(key, comment) \
[[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:@"Evernote"]

#define kUserDefinedNotebookName @"EVERNOTE_USERDEFINEDNOTEBOOKNAME"
#define kUserDefinedNotebookGUID @"EVERNOTE_USERDEFINEDNOTEBOOKGUID"

#define kENNoteContentTemplateName @"ENNoteContentTemplate"