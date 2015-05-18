//
//  YelpUtils.h
//  Savoir
//
//  Created by Nirav Saraiya on 5/12/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YelpReceiver <NSObject>

-(void)receivedBusinessInfoForBusinessId:(NSString *)businessID Rating:(NSNumber *)rating ReviewCount:(NSNumber *)reviewCount Deals:(NSArray *)deals Error:(NSError *)error;

@end

@interface YelpUtils : NSObject

-(void)queryBusinessInfoForBusinessId:(NSString *)businessID Receiver:(id<YelpReceiver>)receiver;

@end
