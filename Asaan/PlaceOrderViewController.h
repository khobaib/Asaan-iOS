//
//  PlaceOrderViewController.h
//  Asaan
//
//  Created by MC MINI on 10/26/14.
//  Copyright (c) 2014 Tech Fiesta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLStoreendpoint.h"

@interface PlaceOrderViewController : UIViewController<UITextFieldDelegate>

@property GTLStoreendpointStoreMenuItem *item;

@property IBOutlet UILabel *itemName;
@property IBOutlet UILabel *price;
@property IBOutlet UILabel *quantity;
@property IBOutlet UITextField *specialPropertyLabel;
@property IBOutlet UIStepper *stepper;

@property IBOutlet UIView *holderview;



@end
