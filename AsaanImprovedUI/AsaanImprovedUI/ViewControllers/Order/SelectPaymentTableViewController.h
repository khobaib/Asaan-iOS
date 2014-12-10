//
//  SelectPaymentTableTableViewController.h
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 12/5/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLStoreendpoint.h"
#import "GTLUserendpointUserAddress.h"
#import "GTLUserendpointUserCard.h"
#import "GTLUserendpointUserCardCollection.h"

@interface SelectPaymentTableViewController : UITableViewController

@property (strong, nonatomic) GTLStoreendpointStore *selectedStore;
@property (strong, nonatomic) GTLUserendpointUserAddress *savedUserAddress;
@property (strong, nonatomic) GTLUserendpointUserCard *savedUserCard;
@property (strong, nonatomic) GTLUserendpointUserCardCollection *userCards;
@property (nonatomic) int orderType;

@property (nonatomic, assign) bool fromFront;

@end
