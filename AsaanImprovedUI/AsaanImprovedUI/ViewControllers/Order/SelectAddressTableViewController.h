//
//  SelectAddressTableViewController.h
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 12/5/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLStoreendpointStore.h"
#import "GTLUserendpointUserAddressCollection.h"
#import "GTLUserendpointUserAddress.h"

@interface SelectAddressTableViewController : UITableViewController
@property (strong, nonatomic) GTLStoreendpointStore *selectedStore;
@property (strong, nonatomic) GTLUserendpointUserAddressCollection *userAddresses;
@property (strong, nonatomic) GTLUserendpointUserAddress *savedUserAddress;
@property (nonatomic) int orderType;
@end
