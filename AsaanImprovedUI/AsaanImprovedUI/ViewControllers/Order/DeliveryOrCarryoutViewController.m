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
#import "MenuTableViewController.h"
#import "UtilCalls.h"

@interface DeliveryOrCarryoutViewController ()

@property (weak, nonatomic) IBOutlet UILabel *txtCarryout;
@property (weak, nonatomic) IBOutlet UILabel *txtDelivery;
@property (strong, nonatomic) GTLUserendpointUserCardCollection *userCards;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (weak, nonatomic) IBOutlet UILabel *orderTime;
@property (weak, nonatomic) IBOutlet UILabel *partySize;

@property (nonatomic) long minOrderTime;
@property (nonatomic) long timeIncrementInterval;
@property (nonatomic) long timeDecrementInterval;
@property (nonatomic) long minPartySize;
@property (nonatomic) long currPartySize;
@property (nonatomic) NSDate *currOrderTime;

@property (nonatomic) Boolean bIsSeekingDeliveryAddress;
@end

@implementation DeliveryOrCarryoutViewController
@synthesize selectedStore = _selectedStore;

+ (int) ORDERTYPE_CARRYOUT { return 0;}
+ (int) ORDERTYPE_DELIVERY { return 1;}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.minPartySize = self.currPartySize = 1;
    self.partySize.text = [NSString stringWithFormat:@"%ld", self.currPartySize];
    self.minOrderTime = 3600;
    self.timeIncrementInterval = 900; // 15 min
    self.timeDecrementInterval = -900; // 15 min
    
    NSDate *currentTime = [NSDate date];
    NSDate *minOrderDate = [currentTime dateByAddingTimeInterval:self.minOrderTime];
    self.currOrderTime = minOrderDate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    self.orderTime.text = [dateFormatter stringFromDate: self.currOrderTime];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barTintColor = [UIColor asaanBackgroundColor];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    if (self.selectedStore.providesDelivery.boolValue == NO)
    {
        NSDictionary* attributes = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
        NSString *strMsg = [NSString stringWithFormat:@"Delivery: %@ does not provide delivery", self.selectedStore.name];
        NSAttributedString* attributedString = [[NSAttributedString alloc] initWithString:strMsg attributes:attributes];
        
        self.txtDelivery.attributedText = attributedString;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
//    if (!self.userCards || !self.userCards.items || self.userCards.items.count == 0)
//        [self performSegueWithIdentifier:@"segueAddPaymentMethod" sender:self];
//
//    if (!self.userAddresses || !self.userAddresses.items || self.userAddresses.items.count == 0)
//        [self performSegueWithIdentifier:@"segueAddAddress" sender:self];
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
    if (indexPath.row == 2)
    {
        self.orderType = [DeliveryOrCarryoutViewController ORDERTYPE_CARRYOUT];
        [self performSegueWithIdentifier:@"segueStartOrderToMenu" sender:self];
    }
    else if (indexPath.row == 3)
    {
        if (self.selectedStore.providesDelivery.boolValue == NO)
            return;

        self.orderType = [DeliveryOrCarryoutViewController ORDERTYPE_DELIVERY];
        [self performSegueWithIdentifier:@"segueStartOrderToMenu" sender:self];
    }
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, tableView.frame.size.width, 20)];
    [label setFont:[UIFont boldSystemFontOfSize:14]];
    [label setTextColor:[UIColor colorWithRed:255.0 green:255.0 blue:255.0 alpha:1.0]];
    label.text = @"Let's get your order started";
    
    /* Section header is in 0th index... */
    [view addSubview:label];
    [view setBackgroundColor:[UIColor colorWithRed:48/255.0 green:25/255.0 blue:25/255.0 alpha:1.0]]; //your background color...
    return view;
}

#pragma mark - Action Buttons
- (IBAction)decOrderTime:(id)sender
{
    NSDate *currentTime = [NSDate date];
    NSDate *newTime = [[NSDate alloc] initWithTimeInterval:self.timeDecrementInterval
                                                 sinceDate:self.currOrderTime];
    
    NSDate *minOrderTime = [[NSDate alloc] initWithTimeInterval:self.minOrderTime
                                                      sinceDate:currentTime];
    self.currOrderTime = [newTime laterDate:minOrderTime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    self.orderTime.text = [dateFormatter stringFromDate: self.currOrderTime];
}
- (IBAction)incOrderTime:(id)sender
{
    NSDate *currentTime = [NSDate date];
    NSDate *newTime = [[NSDate alloc] initWithTimeInterval:self.timeIncrementInterval
                                                 sinceDate:self.currOrderTime];
    
    NSDate *minOrderTime = [[NSDate alloc] initWithTimeInterval:self.minOrderTime
                                                      sinceDate:currentTime];
    self.currOrderTime = [newTime laterDate:minOrderTime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    self.orderTime.text = [dateFormatter stringFromDate: self.currOrderTime];
}
- (IBAction)decPartySize:(id)sender
{
    if (self.currPartySize > self.minPartySize)
        self.partySize.text = [NSString stringWithFormat:@"%d", --self.currPartySize];
}
- (IBAction)incPartySize:(id)sender
{
    self.partySize.text = [NSString stringWithFormat:@"%d", ++self.currPartySize];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"segueStartOrderToMenu"])
    {
        MenuTableViewController *controller = [segue destinationViewController];
        [controller setSelectedStore:self.selectedStore];
        [controller setOrderType:self.orderType];
        [controller setPartySize:self.currPartySize];
        [controller setOrderTime:self.currOrderTime];
        [controller setBMenuIsInOrderMode:YES];
    }
    else if ([[segue identifier] isEqualToString:@"segueStartOrderToSelectAddress"])
    {
        SelectAddressTableViewController *controller = [segue destinationViewController];
        [controller setSelectedStore:self.selectedStore];
    }
}

@end
