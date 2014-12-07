//
//  SelectAddressTableViewController.m
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 12/5/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

@import CoreLocation;
#import "SelectAddressTableViewController.h"
#import "SelectPaymentTableViewController.h"
#import "AddAddressTableViewController.h"
#import "UIColor+AsaanGoldColor.h"
#import "UIColor+AsaanBackgroundColor.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "AsaanConstants.h"
#import <Parse/Parse.h>

@interface SelectAddressTableViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) CLGeocoder *geocoder;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic) float meterToMile;
@end

@implementation SelectAddressTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.meterToMile = 0.000621371;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barTintColor = [UIColor asaanBackgroundColor];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor goldColor]};
    
    [self getUserAddresses];
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
    
    if ([self.userAddresses isKindOfClass:[NSNull class]])
        return 1;
    else
        return self.userAddresses.items.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddressCell" forIndexPath:indexPath];
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
        txtTitle.text = userAddress.address1;
        txtAddress.text = userAddress.address2;
    }

    return cell;
}

- (void) getUserAddresses
{
    typeof(self) weakSelf = self;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLServiceUserendpoint *gtlUserService= [appDelegate gtlUserService];
    GTLQueryUserendpoint *query = [GTLQueryUserendpoint queryForGetUserAddresses];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    dic[USER_AUTH_TOKEN_HEADER_NAME] = [PFUser currentUser][@"authToken"];
    [query setAdditionalHTTPHeaders:dic];
    [gtlUserService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error)
     {
         if (!error)
         {
             weakSelf.userAddresses = object;
             [weakSelf.tableView reloadData];
         }
         else
         {
             NSString *errMsg = [NSString stringWithFormat:@"%@", [error userInfo]];
             UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Asaan Server Access Failure" message:errMsg delegate:weakSelf cancelButtonTitle:@"Ok" otherButtonTitles:nil];
             
             [alert show];
             return;
         }
    }];
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
    //
    // TODO Save the coordinates in AddAddress and Remove the call below!!!!
    //
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Please Wait";
    hud.hidden = NO;
    typeof(self) weakSelf = self;
    if (!self.geocoder) self.geocoder = [[CLGeocoder alloc] init];
    [weakSelf.geocoder geocodeAddressString:userAddress.address2 completionHandler:^(NSArray* placemarks, NSError* error)
     {
         if (!error)
         {
             CLPlacemark *placemark = placemarks.firstObject;
             CLLocation* first = [[CLLocation alloc] initWithLatitude:placemark.location.coordinate.latitude longitude:placemark.location.coordinate.longitude];
             CLLocation* second = [[CLLocation alloc] initWithLatitude:weakSelf.selectedStore.lat.doubleValue longitude:weakSelf.selectedStore.lng.doubleValue];
             
             CGFloat distance = [first distanceFromLocation:second];
             NSInteger maxDistance = floorf(distance * weakSelf.meterToMile);
             
             if (maxDistance > weakSelf.selectedStore.deliveryDistance.intValue)
             {
                 NSString *errMsg = [NSString stringWithFormat:@"Address is out of %@'s delivery range", weakSelf.selectedStore.name];
                 UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error" message:errMsg delegate:weakSelf cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                 
                 hud.hidden = YES;
                 [alert show];
                 return;
             }
             else
             {
                 hud.hidden = YES;
                 weakSelf.savedUserAddress = userAddress;
                 [weakSelf performSegueWithIdentifier:@"segueAddressToPayment" sender:weakSelf];
             }
         }
         else
         {
             NSString *errMsg = [NSString stringWithFormat:@"%@", [error userInfo]];
             UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Address not found" message:errMsg delegate:weakSelf cancelButtonTitle:@"Ok" otherButtonTitles:nil];
             
             hud.hidden = YES;
             [alert show];
             return;
         }
     }];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segueAddressToPayment"])
    {
        SelectPaymentTableViewController *controller = [segue destinationViewController];
        [controller setSelectedStore:self.selectedStore];
        [controller setSavedUserAddress:self.savedUserAddress];
        [controller setOrderType:self.orderType];
    }
}

- (IBAction)unwindToSelectAddress:(UIStoryboardSegue *)unwindSegue
{
    NSLog(@"Back to SelectAddressTableViewController");
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
