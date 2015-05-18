//
//  YelpUtils.m
//  Savoir
//
//  Created by Nirav Saraiya on 5/12/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "YelpUtils.h"
#import "NSURLRequest+OAuth.h"
#import "AFURLSessionManager.h"

/**
 Default paths and search terms used in this example
 */
static NSString * const kAPIHost           = @"api.yelp.com";
static NSString * const kBusinessPath      = @"/v2/business/";

@interface YelpUtils()
@property (strong, nonatomic) NSMutableDictionary *allBusinesses;
@end

@implementation YelpUtils

- (id)init
{
    if (self = [super init])
    {
        self.allBusinesses = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)queryBusinessInfoForBusinessId:(NSString *)businessID Receiver:(id<YelpReceiver>)receiver
{
    NSMutableDictionary *existingBusinessInfoWithDate = [self.allBusinesses objectForKey:businessID];
    if (existingBusinessInfoWithDate != nil)
    {
        NSNumber *reviewCount = [existingBusinessInfoWithDate objectForKey:@"review_count"];
        NSNumber *rating = [existingBusinessInfoWithDate objectForKey:@"rating"];
        NSArray *deals = [existingBusinessInfoWithDate objectForKey:@"deals"] ;
        [receiver receivedBusinessInfoForBusinessId:businessID Rating:rating ReviewCount:reviewCount Deals:deals Error:nil];
        
        NSDate *existingInfoRefreshDate = [existingBusinessInfoWithDate objectForKey:@"BusinessInfoQueryDate"];
        NSDate *currentDate = [NSDate date];
        NSDate *compareDate = [existingInfoRefreshDate dateByAddingTimeInterval:86400];
        if ([compareDate compare:currentDate] == NSOrderedDescending)
            return;
    }
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSString *businessPath = [NSString stringWithFormat:@"%@%@", kBusinessPath, businessID];
    NSURLRequest *businessInfoRequest = [NSURLRequest requestWithHost:kAPIHost path:businessPath];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:businessInfoRequest completionHandler:^(NSURLResponse *response, id responseObject, NSError *error)
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (!error && httpResponse.statusCode == 200)
        {
            NSDictionary *businessResponseJSON = responseObject;
            
            NSMutableDictionary *businessInfoWithDate = [businessResponseJSON mutableCopy];
            [businessInfoWithDate setObject:[NSDate date] forKey:@"BusinessInfoQueryDate"];
            [self.allBusinesses setObject:businessInfoWithDate forKey:businessID];
            
            NSNumber *reviewCount = [businessInfoWithDate objectForKey:@"review_count"];
            NSNumber *rating = [businessInfoWithDate objectForKey:@"rating"];
            NSArray *deals = [existingBusinessInfoWithDate objectForKey:@"deals"] ;
            [receiver receivedBusinessInfoForBusinessId:businessID Rating:rating ReviewCount:reviewCount Deals:deals Error:nil];
        } else
        {
            [receiver receivedBusinessInfoForBusinessId:businessID Rating:nil ReviewCount:nil Deals:nil Error:nil];
        }
    }];
    [dataTask resume];
}

@end
