//
//  MenuModifierGroupViewController.h
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 12/7/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLStoreendpointStoreMenuItem.h"
#import "GTLStoreendpoint.h"
#import "GTLUserendpointUserAddress.h"
#import "GTLUserendpointUserCard.h"

@interface MenuModifierGroupViewController : UIViewController
@property (strong, nonatomic) GTLStoreendpointStore *selectedStore;
@property (strong, nonatomic) GTLStoreendpointStoreMenuItem *selectedMenuItem;
@property (strong, nonatomic) GTLUserendpointUserAddress *savedUserAddress;
@property (strong, nonatomic) GTLUserendpointUserCard *savedUserCard;
@property (nonatomic) int orderType;
@property (nonatomic) NSInteger partySize;
@property (nonatomic) NSDate *orderTime;
@end
