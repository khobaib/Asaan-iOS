//
//  StripePay.m
//  Savoir
//
//  Created by Nirav Saraiya on 3/3/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "StripePay.h"

#import "Constants.h"
#import "STPTestPaymentAuthorizationViewController.h"
#import "PKPayment+STPTestKeys.h"

@interface StripePay ()<PKPaymentAuthorizationViewControllerDelegate>

@property (nonatomic) BOOL applePaySucceeded;
@property (nonatomic) NSError *applePayError;
@property (strong, nonatomic) UIViewController *sender;

- (NSArray *)summaryItemsWithTitle:(NSString *)title Label:(NSString *)label AndAmount:(NSDecimalNumber *)amount;

@end

@implementation StripePay

/**
 *  Replace these with your own values and then remove this warning.
 *  Make sure to replace the values in Example/Parse/config/global.json as well if you want to use Parse.
 */

// This can be found at https://dashboard.stripe.com/account/apikeys
// NSString *const StripePublishableKey = @"pk_live_4Ns4PhSHMwuwXpCI1nfAdFrZ";
NSString *const StripePublishableKey = @"pk_test_4Ns4Xp8GtdBUxhiUKDi4RMTa";

// To set this up, check out https://github.com/stripe/example-ios-backend
// This should be in the format https://my-shiny-backend.herokuapp.com
NSString *const BackendChargeURLString = nil; // TODO: replace nil with your own value

// To learn how to obtain an Apple Merchant ID, head to https://stripe.com/docs/mobile/apple-pay
NSString *const AppleMerchantId = @"merchant.com.savoirexp.savoir"; // TODO: replace nil with your own value

+ (BOOL)applePayEnabled {
    if ([PKPaymentRequest class])
    {
        PKPaymentRequest *paymentRequest = [Stripe paymentRequestWithMerchantIdentifier:AppleMerchantId];
        return [Stripe canSubmitPaymentRequest:paymentRequest];
    }
    return NO;
}

- (NSArray *)summaryItemsWithTitle:(NSString *)title Label:(NSString *)label AndAmount:(NSDecimalNumber *)amount {
    PKPaymentSummaryItem *orderItem = [PKPaymentSummaryItem summaryItemWithLabel:label amount:amount];
    PKPaymentSummaryItem *totalItem = [PKPaymentSummaryItem summaryItemWithLabel:title amount:amount];
    return @[orderItem, totalItem];
}

- (void)beginApplePay:(UIViewController *)sender Title:(NSString *)title Label:(NSString *)label AndAmount:(NSDecimalNumber *)amount
{
    self.applePaySucceeded = NO;
    self.applePayError = nil;
    
    NSString *merchantId = AppleMerchantId;
    
    PKPaymentRequest *paymentRequest = [Stripe paymentRequestWithMerchantIdentifier:merchantId];
    if ([Stripe canSubmitPaymentRequest:paymentRequest]) {
//        [paymentRequest setRequiredShippingAddressFields:PKAddressFieldPostalAddress];
//        [paymentRequest setRequiredBillingAddressFields:PKAddressFieldPostalAddress];
//        paymentRequest.shippingMethods = [self.shippingManager defaultShippingMethods];
        paymentRequest.paymentSummaryItems = [self summaryItemsWithTitle:title Label:label AndAmount:amount];
#if DEBUG
        STPTestPaymentAuthorizationViewController *auth = [[STPTestPaymentAuthorizationViewController alloc] initWithPaymentRequest:paymentRequest];
#else
        PKPaymentAuthorizationViewController *auth = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:paymentRequest];
#endif
        self.sender = sender;
        auth.delegate = self;
        [sender presentViewController:auth animated:YES completion:nil];
    }
}

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus))completion {
//#if DEBUG // This is to handle a test result from ApplePayStubs
//    if (payment.stp_testCardNumber) {
//        STPCard *card = [STPCard new];
//        card.number = payment.stp_testCardNumber;
//        card.expMonth = 12;
//        card.expYear = 2020;
//        card.cvc = @"123";
//        [[STPAPIClient sharedClient] createTokenWithCard:card
//                                              completion:^(STPToken *token, NSError *error) {
//                                                  [self createBackendChargeWithToken:token
//                                                                          completion:^(STPBackendChargeResult status, NSError *error) {
//                                                                              if (status == STPBackendChargeResultSuccess) {
//                                                                                  self.applePaySucceeded = YES;
//                                                                                  completion(PKPaymentAuthorizationStatusSuccess);
//                                                                              } else {
//                                                                                  self.applePayError = error;
//                                                                                  completion(PKPaymentAuthorizationStatusFailure);
//                                                                              }
//                                                                          }];
//                                                  
//                                              }];
//        return;
//    }
//#endif
    [[STPAPIClient sharedClient] createTokenWithPayment:payment completion:^(STPToken *token, NSError *error)
    {
        self.token = token;
        
    }];
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    if (self.applePaySucceeded) {
        [self paymentSucceeded];
    } else {
        [self presentError:self.applePayError];
    }
//    [self.sender dismissViewControllerAnimated:YES completion:nil];
//    self.applePaySucceeded = NO;
//    self.applePayError = nil;
}

#pragma mark - Internal
- (void)presentError:(NSError *)error {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:nil
                                                      message:[error userInfo][@"error"]
                                                     delegate:nil
                                            cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                            otherButtonTitles:nil];
    [message show];
}

- (void)paymentSucceeded {
    [[[UIAlertView alloc] initWithTitle:@"Success!"
                                message:@"Payment successfully created!"
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}

- (void)createBackendChargeWithToken:(STPToken *)token completion:(STPTokenSubmissionHandler)completion
{
//    NSDictionary *chargeParams = @{ @"stripeToken": token.tokenId, @"amount": @"1000" };
    
//    // This passes the token off to our payment backend, which will then actually complete charging the card using your Stripe account's secret key
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    [manager POST:[BackendChargeURLString stringByAppendingString:@"/charge"]
//       parameters:chargeParams
//          success:^(AFHTTPRequestOperation *operation, id responseObject) { completion(STPBackendChargeResultSuccess, nil); }
//          failure:^(AFHTTPRequestOperation *operation, NSError *error) { completion(STPBackendChargeResultFailure, error); }];
}

@end
