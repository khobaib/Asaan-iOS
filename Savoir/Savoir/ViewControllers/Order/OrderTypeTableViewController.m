//
//  OrderTypeTableViewController.m
//  Savoir
//
//  Created by Nirav Saraiya on 4/28/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "OrderTypeTableViewController.h"
#include "OrderTimeTableViewController.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "MenuTableViewController.h"
#import "UtilCalls.h"
#include "InStoreUtils.h"

@interface OrderTypeTableViewController ()

@property (weak, nonatomic) IBOutlet UILabel *txtCarryout;
@property (weak, nonatomic) IBOutlet UILabel *txtDelivery;
@property (weak, nonatomic) IBOutlet UILabel *txtDineIn;
@end

@implementation OrderTypeTableViewController
@synthesize selectedStore = _selectedStore;

+ (int) ORDERTYPE_CARRYOUT { return 1;}
+ (int) ORDERTYPE_DELIVERY { return 2;}
+ (int) ORDERTYPE_PREVISIT { return 3;};
+ (int) ORDERTYPE_DININGIN { return 4;};

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableHeaderView = [UtilCalls setupStaticHeaderViewForTable:self.tableView WithTitle:self.selectedStore.name AndSubTitle:@"Please select your order type."];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.selectedStore.providesDelivery.boolValue == NO)
    {
        NSDictionary* attributes = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
        NSString *strMsg = [NSString stringWithFormat:@"Delivery: %@ does not provide delivery", self.selectedStore.name];
        NSAttributedString* attributedString = [[NSAttributedString alloc] initWithString:strMsg attributes:attributes];
        
        self.txtDelivery.attributedText = attributedString;
    }
    
    if (self.selectedStore.providesCarryout.boolValue == NO)
    {
        NSDictionary* attributes = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
        NSString *strMsg = [NSString stringWithFormat:@"Carryout: %@ does not provide carryout", self.selectedStore.name];
        NSAttributedString* attributedString = [[NSAttributedString alloc] initWithString:strMsg attributes:attributes];
        
        self.txtCarryout.attributedText = attributedString;
    }
    
    if (self.selectedStore.providesDineInAndPay.boolValue == NO)
    {
        NSDictionary* attributes = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
        NSString *strMsg = [NSString stringWithFormat:@"Dine In: %@ does not provide mobile pay at the table", self.selectedStore.name];
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

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        if (self.selectedStore.providesDineInAndPay.boolValue == NO)
            return;
        [InStoreUtils startInStoreMode:self ForStore:self.selectedStore InBeaconMode:false];
    }
    else if (indexPath.row == 1)
    {
        if (self.selectedStore.providesCarryout.boolValue == NO)
            return;
        self.orderType = [OrderTypeTableViewController ORDERTYPE_CARRYOUT];
        [self performSegueWithIdentifier:@"segueOrderTypeToTime" sender:self];
    }
    else if (indexPath.row == 2)
    {
        if (self.selectedStore.providesDelivery.boolValue == NO)
            return;
        
        self.orderType = [OrderTypeTableViewController ORDERTYPE_DELIVERY];
        [self performSegueWithIdentifier:@"segueOrderTypeToTime" sender:self];
    }
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"segueOrderTypeToTime"])
    {
        OrderTimeTableViewController *controller = [segue destinationViewController];
        [controller setSelectedStore:self.selectedStore];
        [controller setOrderType:self.orderType];
    }
}

@end
