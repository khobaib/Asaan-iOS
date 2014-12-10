//
//  AddPaymentCardViewController.h
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 12/5/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLUserendpointUserCard.h"
#include "BaseViewController.h"

#import "GTLStoreendpoint.h"
#import "GTLUserendpointUserAddress.h"
#import "GTLUserendpointUserCard.h"
#import "GTLUserendpointUserCardCollection.h"

@interface AddPaymentCardViewController : BaseViewController

@property (strong, nonatomic) GTLUserendpointUserCard *savedUserCard;

@end
