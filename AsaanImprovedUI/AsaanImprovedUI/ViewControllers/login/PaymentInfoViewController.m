//
//  StripeViewController.m
//  AsaanImprovedUI
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

#import "UIColor+AsaanGoldColor.h"
#import "UIColor+AsaanBackgroundColor.h"
#import "DropdownView.h"
#import "MBProgressHUD.h"
#import "AsaanConstants.h"

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
    self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor : [UIColor goldColor]};
    
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
        
        [[[UIAlertView alloc]initWithTitle:@"Error" message:@"The card number you have enterd is not a valid card number" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
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

-(void)saveCardAtParse
{
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
            
            PFObject *tokenOb=[PFObject objectWithClassName:@"UserStripeCard"];
            
            [self addPfObject:tokenOb forKey:@"address_city" value:token.card.addressCity];
            [self addPfObject:tokenOb forKey:@"address_country" value:token.card.addressCountry];
            [self addPfObject:tokenOb forKey:@"address_line1" value:token.card.addressLine1];
            [self addPfObject:tokenOb forKey:@"address_line2" value:token.card.addressLine2];
            [self addPfObject:tokenOb forKey:@"address_state" value:token.card.addressState];
            [self addPfObject:tokenOb forKey:@"address_zip" value:token.card.addressZip];
            [self addPfObject:tokenOb forKey:@"country" value:token.card.country];
            [self addPfObject:tokenOb forKey:@"cvc_check" value:token.card.cvc];
            [self addPfObject:tokenOb forKey:@"exp_year" value:[NSNumber numberWithInt:token.card.expYear]];
            [self addPfObject:tokenOb forKey:@"exp_month" value:[NSNumber numberWithInt:token.card.expMonth]];
            [self addPfObject:tokenOb forKey:@"fingerprint" value:token.card.fingerprint];
            [self addPfObject:tokenOb forKey:@"last4" value:token.card.last4];
            [self addPfObject:tokenOb forKey:@"name" value:token.card.name];
            [self addPfObject:tokenOb forKey:@"stripeCardid" value:token.card.number];
            [self addPfObject:tokenOb forKey:@"user" value:[PFUser currentUser]];
            
            
            /*   tokenOb[@"address_city"]=token.card.addressCity;
             tokenOb[@"address_country"]=token.card.addressCountry;
             tokenOb[@"address_line1"]=token.card.addressLine1;
             tokenOb[@"address_line2"]=token.card.addressLine2;
             tokenOb[@"address_state"]=token.card.addressState;
             tokenOb[@"address_zip"]=token.card.addressZip;
             tokenOb[@"brand"]=token.card.type;
             tokenOb[@"country"]=token.card.country;
             tokenOb[@"cvc_check"]=token.card.cvc;
             tokenOb[@"exp_year"]=[NSNumber numberWithInt:token.card.expYear] ;
             tokenOb[@"exp_month"]=[NSNumber numberWithInt:token.card.expMonth];
             tokenOb[@"fingerprint"]=token.card.fingerprint;
             
             tokenOb[@"last4"]=token.card.last4;
             
             tokenOb[@"name"]=token.card.name;
             
             tokenOb[@"stripeCardid"]=token.card.number;
             tokenOb[@"user"]=[PFUser currentUser];*/
            
            [tokenOb saveEventually:^(BOOL success,NSError *error) {
                
                if(success){
                    NSLog(@"done");
                }else{
                    NSLog(@"%@",[error userInfo]);
                }
                
                [MBProgressHUD hideHUDForView:self.view animated:true];
            }];
            
            // submit the token to your payment backend as you did previously
        }
    }];
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
//            card.createdDate = [NSNumber numberWithBool:0];   // ???
//            card.currency = @"";   // ???
//            card.defaultProperty = [NSNumber numberWithBool:false];   // ???
            card.expMonth = [NSNumber numberWithInteger:token.card.expMonth];
            card.expYear = [NSNumber numberWithInteger:token.card.expYear];
//            card.fundingType = @"";   // ???
//            card.identifier = [NSNumber numberWithBool:false];
            card.last4 = token.card.last4;
//            card.modifiedDate = [NSNumber numberWithBool:false];   // ???
            card.name = token.card.name;
//            card.provider = @"";   // ???
//            card.providerCustomerId = @"";   // ???
//            card.refreshToken = @"";   // ???
            card.state = token.card.addressState;
//            card.userId = [NSNumber numberWithBool:false];   // ???
            card.zip = token.card.addressZip;
            
            GTLQueryUserendpoint *query = [GTLQueryUserendpoint queryForSaveUserCardWithObject:card];
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            dic[USER_AUTH_TOKEN_HEADER_NAME] = [PFUser currentUser][@"authToken"];
            [query setAdditionalHTTPHeaders:dic];
            
            [userService executeQuery:query completionHandler:^(GTLServiceTicket * ticket,GTLUserendpointUserCard *object, NSError *error ) {
                
                if (error) {
                    
                    [[[UIAlertView alloc]initWithTitle:@"Error" message:[error.userInfo description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                    NSLog(@"%@",[error userInfo]);
                } else {
                    
                    NSLog(@"done %@", object.name);
                }
                
                [MBProgressHUD hideHUDForView:self.view animated:true];
            }];
        }
    }];
}

@end
