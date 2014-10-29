//
//  Order.h
//  Asaan
//
//  Created by MC MINI on 10/29/14.
//  Copyright (c) 2014 Tech Fiesta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Order : NSManagedObject

@property (nonatomic, retain) NSNumber * menuItemPOSId;
@property (nonatomic, retain) NSNumber * menuItemPosition;
@property (nonatomic, retain) NSString * menuName;
@property (nonatomic, retain) NSNumber * menuPOSId;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) NSString * shortDescriptionProperty;
@property (nonatomic, retain) NSNumber * storeId;
@property (nonatomic, retain) NSNumber * subMenuPOSId;
@property (nonatomic, retain) NSNumber * userID;
@property (nonatomic, retain) NSString * username;

@end
