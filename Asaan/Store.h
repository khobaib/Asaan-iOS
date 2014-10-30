//
//  Store.h
//  Asaan
//
//  Created by MC MINI on 10/22/14.
//  Copyright (c) 2014 Tech Fiesta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "GTLStoreendpoint.h"


@interface Store : NSManagedObject

+(GTLStoreendpointStore *)gtlStoreFromStore:(Store *)store;
+(GTLStoreendpointStore *)gtlStoreFromID:(id)store;

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * backgroundimagethumbnilurl;
@property (nonatomic, retain) NSString * backgroundimageurl;
@property (nonatomic, retain) NSString * beaconid;
@property (nonatomic, retain) NSString * bssid;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSNumber * createddate;
@property (nonatomic, retain) NSString * fburl;
@property (nonatomic, retain) NSString * gplusurl;
@property (nonatomic, retain) NSString * hourse;
@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lon;
@property (nonatomic, retain) NSNumber * modifiedDate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSNumber * priceRange;
@property (nonatomic, retain) NSString * rewardDescription;
@property (nonatomic, retain) NSNumber * rewardSrate;
@property (nonatomic, retain) NSNumber * isActive;
@property (nonatomic, retain) NSString * ssid;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * storeDescription;
@property (nonatomic, retain) NSNumber * storeId;
@property (nonatomic, retain) NSString * subtype;
@property (nonatomic, retain) NSString * trophies;
@property (nonatomic, retain) NSString * twitterUrl;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * websiteurl;
@property (nonatomic, retain) NSString * zip;

@end
