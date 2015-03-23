//
//  SelectAddressTableViewController.m
//  Savoir
//
//  Created by Nirav Saraiya on 12/5/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

@import CoreLocation;
#import "SelectAddressTableViewController.h"
#import "SelectPaymentTableViewController.h"
#import "AddAddressTableViewController.h"
#import "UIColor+SavoirGoldColor.h"
#import "UIColor+SavoirBackgroundColor.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>
#import "UtilCalls.h"

@interface SelectAddressTableViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) GTLUserendpointUserAddressCollection *userAddresses;
@property (strong, nonatomic) GTLUserendpointUserAddress *savedUserAddress;
@property (strong, nonatomic) CLGeocoder *geocoder;
@property (nonatomic, strong) MBProgressHUD *hud;
@end

@implementation SelectAddressTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
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
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    self.userAddresses = appDelegate.globalObjectHolder.userAddresses;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (self.userAddresses == nil)
        return 1;
    else
        return self.userAddresses.items.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddressCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    UILabel *txtTitle=(UILabel *)[cell viewWithTag:501];
    UILabel *txtAddress=(UILabel *)[cell viewWithTag:502];
    
    if (self.userAddresses.items.count == indexPath.row)
    {
        txtTitle.text = @"Add Address";
        txtAddress.text = nil;
    }
    else
    {
        GTLUserendpointUserAddress *userAddress = [self.userAddresses.items objectAtIndex:indexPath.row];
        txtTitle.text = userAddress.title;
        txtAddress.text = userAddress.fullAddress;
    }

    return cell;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewCell *headerCell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
    if (self.selectedStore != nil)
        [UtilCalls setupHeaderView:headerCell WithTitle:self.selectedStore.name AndSubTitle:@"Select Delivery Address"];
    return headerCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.savedUserAddress = nil;
    if (self.userAddresses.items.count == indexPath.row)
    {
        [self performSegueWithIdentifier:@"segueAddAddress" sender:self];
        return;
    }

    GTLUserendpointUserAddress *userAddress = [self.userAddresses.items objectAtIndex:indexPath.row];
    CLLocation* first = [[CLLocation alloc] initWithLatitude:userAddress.lat.doubleValue longitude:userAddress.lng.doubleValue];

    if (![UtilCalls isDistanceBetweenPointA:first AndStore:self.selectedStore withinRange:self.selectedStore.deliveryDistance.intValue])
    {
        NSString *errMsg = [NSString stringWithFormat:@"Address is out of %@'s delivery range", self.selectedStore.name];
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error" message:errMsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
    else
    {
        self.savedUserAddress = userAddress;
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        appDelegate.globalObjectHolder.defaultUserAddress = userAddress;
       [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([[segue identifier] isEqualToString:@"segueAddressToPayment"])
//    {
//        SelectPaymentTableViewController *controller = [segue destinationViewController];
//        [controller setSelectedStore:self.selectedStore];
//        [controller setSavedUserAddress:self.savedUserAddress];
//        [controller setOrderType:self.orderType];
//    }
//}

- (IBAction)unwindToSelectAddress:(UIStoryboardSegue *)unwindSegue
{
//    NSLog(@"Back to SelectAddressTableViewController");
//    UIViewController *cc = [unwindSegue sourceViewController];
//
//    if ([cc isKindOfClass:[AddAddressTableViewController class]])
//    {
//        AddAddressTableViewController *controller = (AddAddressTableViewController *)cc;
//        self.savedUserAddress = controller.savedUserAddress;
//        if (![self.savedUserAddress isKindOfClass:[NSNull class]])
//            [self performSegueWithIdentifier:@"segueAddressToPayment" sender:self];
//    }
}


@end
