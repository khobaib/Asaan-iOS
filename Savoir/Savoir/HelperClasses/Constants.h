//
//  Constants.h
//  Savoir
//
//  Created by Nirav Saraiya on 1/15/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#ifndef Savoir_Constants_h
#define Savoir_Constants_h

#define USER_AUTH_TOKEN_HEADER_NAME @"asaan-auth-token"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

extern const NSUInteger FluentPagingTablePreloadMargin;
extern const NSUInteger FluentPagingTablePageSize;
extern const NSTimeInterval DataLoadingOperationDuration;


#endif
