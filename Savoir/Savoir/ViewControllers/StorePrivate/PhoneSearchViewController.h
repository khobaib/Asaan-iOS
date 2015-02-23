//
//  PhoneSearchViewController.h
//  Savoir
//
//  Created by Nirav Saraiya on 2/10/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhoneSearchReceiver.h"

@interface PhoneSearchViewController : UIViewController

@property (weak) id <PhoneSearchReceiver> receiver;

@end
