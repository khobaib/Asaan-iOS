//
//  AddPaymentCardViewController.m
//  Savoir
//
//  Created by Nirav Saraiya on 12/5/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "AddPaymentCardViewController.h"

#import "PTKView.h"
#import "STPCard.h"
#import "Stripe.h"

#import <Parse/Parse.h>
#import <GTLUserendpoint.h>

#import "UIColor+SavoirGoldColor.h"
#import "UIColor+SavoirBackgroundColor.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "UtilCalls.h"
#import "SelectPaymentTableViewController.h"

@interface AddPaymentCardViewController ()<PTKViewDelegate>
@property (weak, nonatomic) IBOutlet PTKView *ptkView;
@property (strong, nonatomic) IBOutlet UIScrollView *paymentInfoScrollView;

@end

@implementation AddPaymentCardViewController {
    
    BOOL _isCardValid;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [super setBaseScrollView:_paymentInfoScrollView];
    self.ptkView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    appDelegate.topViewController = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)savePaymentClicked:(id)sender
{
    if (_isCardValid) {
        [self saveCardAtGAE];
    }
    else {
        
        [[[UIAlertView alloc]initWithTitle:@"Error" message:@"The card number you have entered is not valid." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        return;
    }
}

#pragma mark - PTKViewDelegate
- (void)paymentView:(PTKView *)paymentView withCard:(PTKCard *)card isValid:(BOOL)valid {
    
    _isCardValid = valid;
    if (valid) {
        [self.view endEditing:YES];
    }
}

- (NSString *)getCardTypeForCard:(PTKCardNumber *)cardNumber
{
    PTKCardType cardType = [cardNumber cardType];
    NSString *cardTypeName = @"placeholder";
    
    switch (cardType) {
        case PTKCardTypeAmex:
            cardTypeName = @"amex";
            break;
        case PTKCardTypeDinersClub:
            cardTypeName = @"diners";
            break;
        case PTKCardTypeDiscover:
            cardTypeName = @"discover";
            break;
        case PTKCardTypeJCB:
            cardTypeName = @"jcb";
            break;
        case PTKCardTypeMasterCard:
            cardTypeName = @"mastercard";
            break;
        case PTKCardTypeVisa:
            cardTypeName = @"visa";
            break;
        default:
            break;
    }
    return cardTypeName;
}

- (void)saveCardAtGAE {
    
    __weak __typeof(self) weakSelf = self;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLServiceUserendpoint *gtlUserService= [appDelegate gtlUserService];
    
    STPCard *card = [[STPCard alloc] init];
    card.number = self.ptkView.card.number;
    card.expMonth = self.ptkView.card.expMonth;
    card.expYear = self.ptkView.card.expYear;
    card.cvc = self.ptkView.card.cvc;
    card.addressZip = self.ptkView.card.addressZip;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[STPAPIClient sharedClient] createTokenWithCard:card completion:^(STPToken *token, NSError *error)
    {
        if (!error)
        {
            GTLUserendpointUserCard *card = [[GTLUserendpointUserCard alloc] init];
            card.accessToken = token.tokenId;
            card.address = token.card.addressLine1;
            card.type = [weakSelf getCardTypeForCard:weakSelf.ptkView.cardNumber];
            card.brand = [NSNumber numberWithInt:token.card.brand];
            card.city = token.card.addressCity;
            card.country = token.card.country;
            card.cardId = token.card.cardId;
            card.fingerprint = token.card.fingerprint;
            card.expMonth = [NSNumber numberWithInteger:token.card.expMonth];
            card.expYear = [NSNumber numberWithInteger:token.card.expYear];
            //            card.fundingType = @"";   // ???
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
            dic[USER_AUTH_TOKEN_HEADER_NAME] = [UtilCalls getAuthTokenForCurrentUser];
            [query setAdditionalHTTPHeaders:dic];
            
            [gtlUserService executeQuery:query completionHandler:^(GTLServiceTicket * ticket,GTLUserendpointUserCard *object, NSError *error )
            {
                [MBProgressHUD hideHUDForView:self.view animated:true];
                if (!error)
                {
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
                    [appDelegate.globalObjectHolder addCardToUserCards:object];
//                    [self.navigationController popViewControllerAnimated:YES];
                    [UtilCalls popFrom:self index:2 Animated:YES];
                } else
                    [[[UIAlertView alloc]initWithTitle:@"Error" message:[error userInfo][@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            }];
        }
        else
            [[[UIAlertView alloc]initWithTitle:@"Error" message:[error userInfo][@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    
//    if ([segue.identifier isEqualToString:@"segueunwindToSelectPaymentMethod"]) {
//        
//        GTLUserendpointUserCardCollection *cards = [[GTLUserendpointUserCardCollection alloc] init];
//        cards.items = @[self.savedUserCard];
//        
//        SelectPaymentTableViewController *controller = [segue destinationViewController];
//        [controller setUserCards:cards];
//    }
//}

@end
