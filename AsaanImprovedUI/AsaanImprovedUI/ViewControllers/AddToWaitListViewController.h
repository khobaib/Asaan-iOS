//
//  AddToWaitListViewController.h
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 2/11/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddToWaitListReceiver.h"

@interface AddToWaitListViewController : UIViewController

@property (weak) id <AddToWaitListReceiver> receiver;

@end
