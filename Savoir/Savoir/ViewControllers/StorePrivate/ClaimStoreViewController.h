//
//  ClaimStoreViewController.h
//  Savoir
//
//  Created by Nirav Saraiya on 2/10/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLStoreendpoint.h"
#import "PhoneSearchReceiver.h"

@interface ClaimStoreViewController : UIViewController<PhoneSearchReceiver>

@property (strong, nonatomic) GTLStoreendpointStore *selectedStore;

@end
