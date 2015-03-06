//
//  StripePay.h
//  Savoir
//
//  Created by Nirav Saraiya on 3/3/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Stripe.h"

@protocol StripeApplePayReceiver <NSObject>

- (Boolean) placeOrderWithToken:(STPToken *)token;

@end

@interface StripePay : NSObject

extern NSString *const StripePublishableKey;
extern NSString *const BackendChargeURLString;
extern NSString *const AppleMerchantId;

@property (strong, nonatomic) STPToken *token;

- (BOOL)applePayEnabled;
- (void)beginApplePay:(UIViewController *)sender Title:(NSString *)title Label:(NSString *)label AndAmount:(NSDecimalNumber *)amount;

@end
