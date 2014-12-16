//
//  AddAddressTableViewController.h
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 12/5/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLStoreendpointStore.h"
#import "GTLUserendpointUserAddress.h"

@interface AddAddressTableViewController : UITableViewController

@property (strong, nonatomic) GTLStoreendpointStore *selectedStore;
@property (strong, nonatomic) GTLUserendpointUserAddress *savedUserAddress;

@end
