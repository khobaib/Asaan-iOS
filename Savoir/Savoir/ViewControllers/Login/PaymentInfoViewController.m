//
//  StripeViewController.m
//  Savoir
//
//  Created by Nirav Saraiya on 11/10/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "PaymentInfoViewController.h"

#import "PTKView.h"
#import "STPCard.h"
#import "Stripe.h"

#import <Parse/Parse.h>
#import <GTLUserendpoint.h>

#import "UIColor+SavoirGoldColor.h"
#import "UIColor+SavoirBackgroundColor.h"
#import "DropdownView.h"
#import "MBProgressHUD.h"
#import "UtilCalls.h"

@interface PaymentInfoViewController () <PTKViewDelegate, DropdownViewDelegate>

@property (weak, nonatomic) IBOutlet PTKView *ptkView;
@property (weak, nonatomic) IBOutlet UIScrollView *paymentInfoScrollView;
@property (weak, nonatomic) IBOutlet DropdownView *dropdownView;

- (IBAction)paymentSaveClicked:(id)sender;

@end

@implementation PaymentInfoViewController {
    
    BOOL _isCardValid;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [super setBaseScrollView:_paymentInfoScrollView];
    
    self.ptkView.delegate = self;
    
    [self.dropdownView setData:@[@"15%", @"20%", @"25%", @"30%"]];
    self.dropdownView.delegate = self;
    [self.dropdownView setDefaultSelection:1];
    self.dropdownView.listBackgroundColor = [UIColor asaanBackgroundColor];
    self.dropdownView.titleColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    // Prevent keyboard from showing by default
    [self.view endEditing:YES];
}

#pragma mark - Actions
- (IBAction)paymentSaveClicked:(id)sender {
    
    if (_isCardValid) {
        
//        [self saveCardAtParse];
        [self saveCardAtGAE];
    }
    else {
        
        [[[UIAlertView alloc]initWithTitle:@"Error" message:@"Card number is not valid." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        return;
    }
}

#pragma mark - DropdownViewDelegate
- (void)dropdownViewActionForSelectedRow:(int)row sender:(id)sender
{
    NSLog(@"Selected row : %d", row);
}

#pragma mark - PTKViewDelegate
- (void)paymentView:(PTKView *)paymentView withCard:(PTKCard *)card isValid:(BOOL)valid {
    
    _isCardValid = valid;
    if (valid) {
        [self.view endEditing:YES];
    }
}

#pragma mark - Private Methods
-(void)addPfObject:(PFObject *)object forKey:(NSString *)key value:(id)value
{
    if (value == nil) {
        
        object[key] = [NSNull null];
        NSLog(@"null");
        
    } else {
        
        object[key] = value;
        NSLog(@"%@",value);
        
    }
}

- (void)saveCardAtGAE {
    
    static GTLServiceUserendpoint *userService = nil;
    
    if (!userService) {
        
        userService = [[GTLServiceUserendpoint alloc] init];
        userService.retryEnabled = YES;
    }
    
    STPCard *card = [[STPCard alloc] init];
    card.number = self.ptkView.card.number;
    card.expMonth = self.ptkView.card.expMonth;
    card.expYear = self.ptkView.card.expYear;
    card.cvc = self.ptkView.card.cvc;
    card.addressZip = self.ptkView.card.addressZip;
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [Stripe createTokenWithCard:card completion:^(STPToken *token, NSError *error) {
        
        if (error) {
            
            [[[UIAlertView alloc]initWithTitle:@"Error" message:[error.userInfo description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            
        } else {
            
            GTLUserendpointUserCard *card = [[GTLUserendpointUserCard alloc] init];
            card.accessToken = token.tokenId;
            card.address = token.card.addressLine1;
            card.brand = token.card.type;
            card.city = token.card.addressCity;
            card.country = token.card.addressCountry; // ??? or token.card.country
            card.expMonth = [NSNumber numberWithInteger:token.card.expMonth];
            card.expYear = [NSNumber numberWithInteger:token.card.expYear];
            card.last4 = token.card.last4;
            card.name = token.card.name;
            card.state = token.card.addressState;
            card.zip = token.card.addressZip;
            card.cardId = token.card.cardId;
            card.fingerprint = token.card.fingerprint;
            
            GTLQueryUserendpoint *query = [GTLQueryUserendpoint queryForSaveUserCardWithObject:card];
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            dic[USER_AUTH_TOKEN_HEADER_NAME]=[UtilCalls getAuthTokenForCurrentUser];
            [query setAdditionalHTTPHeaders:dic];
            
            [userService executeQuery:query completionHandler:^(GTLServiceTicket * ticket,GTLUserendpointUserCard *object, NSError *error ) {
                
                if (error) {
                    
                    [MBProgressHUD hideHUDForView:self.view animated:true];
                    
                    [[[UIAlertView alloc]initWithTitle:@"Error" message:[error.userInfo description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                    NSLog(@"%@",[error userInfo]);
                } else {
                    
                    NSLog(@"done %@", object.name);
                    
                    [self performSegueWithIdentifier:@"segueUnwindPaymentInfoToStoreList" sender:self];
                }
            }];
        }
    }];
}

@end
