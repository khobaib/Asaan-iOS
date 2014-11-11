//
//  StripeViewController.h
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 11/10/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "Stripe.h"
#import "PTKView.h"

@interface StripeViewController : BaseViewController<PTKViewDelegate>


@property IBOutlet PTKView *ptkView;
@property IBOutlet UIButton *addCard;
@end
