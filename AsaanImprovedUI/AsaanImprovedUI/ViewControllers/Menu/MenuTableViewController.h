//
//  MenuTableViewController.h
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 11/20/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataReceiver.h"
#import "GTLStoreendpoint.h"
#import "GTLUserendpointUserAddress.h"
#import "GTLUserendpointUserCard.h"

@interface MenuTableViewController : UITableViewController <DataReceiver>
@property (strong, nonatomic) GTLStoreendpointStore *selectedStore;
@property (strong, nonatomic) GTLUserendpointUserAddress *savedUserAddress;
@property (strong, nonatomic) GTLUserendpointUserCard *savedUserCard;
@property (nonatomic) int orderType;
@property (nonatomic) NSInteger partySize;
@property (nonatomic) NSDate *orderTime;
@end
