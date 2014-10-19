//
//  StoreImage.h
//  Asaan
//
//  Created by MC MINI on 10/19/14.
//  Copyright (c) 2014 Tech Fiesta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface StoreImage : NSManagedObject

@property (nonatomic, retain) NSNumber * storeImageID;
@property (nonatomic, retain) NSNumber * createdDate;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSNumber * modifiedDate;
@property (nonatomic, retain) NSNumber * storeID;
@property (nonatomic, retain) NSString * thumbnilUrl;

@end
