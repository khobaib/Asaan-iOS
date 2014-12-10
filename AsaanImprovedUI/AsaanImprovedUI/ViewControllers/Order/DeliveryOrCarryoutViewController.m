//
//  DeliveryOrCarryoutViewController.m
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 12/5/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "DeliveryOrCarryoutViewController.h"
#import "SelectAddressTableViewController.h"
#import "AddAddressTableViewController.h"
#import "SelectPaymentTableViewController.h"
#import "UIColor+AsaanGoldColor.h"
#import "UIColor+AsaanBackgroundColor.h"

#import "GTLUserendpointUserAddress.h"
#import "GTLUserendpointUserCard.h"
#import "GTLUserendpointUserCardCollection.h"
#import "AsaanConstants.h"
#import "AppDelegate.h"
#import "PTKCardType.h"
#import <Parse/Parse.h>
#import "MBProgressHUD.h"
#import "AddPaymentCardViewController.h"

@interface DeliveryOrCarryoutViewController ()

@property (weak, nonatomic) IBOutlet UILabel *txtCarryout;
@property (weak, nonatomic) IBOutlet UILabel *txtDelivery;
@property (strong, nonatomic) GTLUserendpointUserCardCollection *userCards;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation DeliveryOrCarryoutViewController
@synthesize selectedStore = _selectedStore;

+ (int) ORDERTYPE_CARRYOUT { return 0;}
+ (int) ORDERTYPE_DELIVERY { return 1;}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barTintColor = [UIColor asaanBackgroundColor];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor : [UIColor goldColor]};
    
    if (self.selectedStore.providesDelivery.boolValue == NO)
    {
        NSDictionary* attributes = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
        NSString *strMsg = [NSString stringWithFormat:@"Delivery: %@ does not provide delivery", self.selectedStore.name];
        NSAttributedString* attributedString = [[NSAttributedString alloc] initWithString:strMsg attributes:attributes];
        
        self.txtDelivery.attributedText = attributedString;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark === UITableViewDelegate ===
#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"Please Wait";
        
        [self getUserCards];
    }
    else
    {
        if (self.selectedStore.providesDelivery.boolValue == NO)
            return;

        self.orderType = [DeliveryOrCarryoutViewController ORDERTYPE_DELIVERY];
        [self performSegueWithIdentifier:@"segueDeliveryAddress" sender:self];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    // Get reference to the destination view controller
    if ([[segue identifier] isEqualToString:@"segueDeliveryAddress"])
    {
        SelectAddressTableViewController *controller = [segue destinationViewController];
        [controller setSelectedStore:_selectedStore];
        [controller setOrderType:_orderType];
    }
    else if ([[segue identifier] isEqualToString:@"segueDeliveryPayment"])
    {
        SelectPaymentTableViewController *controller = [segue destinationViewController];
        [controller setSelectedStore:_selectedStore];
        [controller setUserCards:self.userCards];
        [controller setOrderType:_orderType];
    }
}

#pragma mark - Private Methods
- (void) getUserCards
{
    typeof(self) weakSelf = self;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    GTLServiceUserendpoint *gtlUserService= [appDelegate gtlUserService];
    GTLQueryUserendpoint *query = [GTLQueryUserendpoint queryForGetUserCards];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    dic[USER_AUTH_TOKEN_HEADER_NAME] = [PFUser currentUser][@"authToken"];
    [query setAdditionalHTTPHeaders:dic];
    [gtlUserService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error)
     {
         if (!error)
         {
             weakSelf.userCards = object;
             [MBProgressHUD hideHUDForView:self.view animated:true];
             
             self.orderType = [DeliveryOrCarryoutViewController ORDERTYPE_CARRYOUT];
             [self performSegueWithIdentifier:@"segueDeliveryPayment" sender:self];
             
             
         }
         else
         {
             NSString *errMsg = [NSString stringWithFormat:@"%@", [error userInfo]];
             UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Asaan Server Access Failure" message:errMsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
             
             [alert show];
             return;
         }
     }];
}

@end
