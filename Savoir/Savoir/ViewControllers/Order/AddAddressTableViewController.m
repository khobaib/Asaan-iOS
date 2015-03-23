//
//  AddAddressTableViewController.m
//  Savoir
//
//  Created by Nirav Saraiya on 12/5/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

@import CoreLocation;
@import AddressBookUI;
#import "AddAddressTableViewController.h"
#import "PTKUSAddressZip.h"
#import "PTKTextField.h"
#import "DropdownView.h"
#import "UIColor+SavoirBackgroundColor.h"
#import "InlineCalls.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "UIColor+SavoirGoldColor.h"
#import "UIAlertView+Blocks.h"
#import "UtilCalls.h"

@interface AddAddressTableViewController () <DropdownViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *addressTitle;
@property (weak, nonatomic) IBOutlet UITextField *streetAddress;
@property (weak, nonatomic) IBOutlet UITextField *city;
@property (weak, nonatomic) IBOutlet UITextField *zip;
@property (weak, nonatomic) IBOutlet UITextField *other;
@property (weak, nonatomic) IBOutlet UITextField *aptNo;
@property (weak, nonatomic) IBOutlet DropdownView *state;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) CLGeocoder *geocoder;

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation AddAddressTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableHeaderView = [UtilCalls setupStaticHeaderViewForTable:self.tableView WithTitle:self.selectedStore.name AndSubTitle:@"Add Delivery Address"];
    [self setupDropdownView:self.state];
    
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
    
    UIColor *color = [UIColor lightTextColor];
    self.addressTitle.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Home" attributes:@{NSForegroundColorAttributeName: color}];
    self.streetAddress.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"123 ABC Street" attributes:@{NSForegroundColorAttributeName: color}];
    self.aptNo.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"3306A" attributes:@{NSForegroundColorAttributeName: color}];
    self.city.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Chicago" attributes:@{NSForegroundColorAttributeName: color}];
    self.zip.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"60601" attributes:@{NSForegroundColorAttributeName: color}];
    self.other.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"e.g. Cross street, entrance at back of building, etc." attributes:@{NSForegroundColorAttributeName: color}];
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PTKUSAddressZip *)addressZip
{
    return [PTKUSAddressZip addressZipWithString:self.zip.text];
}

- (BOOL)cardAddressZIPShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{
    NSString *resultString = [self.zip.text stringByReplacingCharactersInRange:range withString:replacementString];
    resultString = [PTKTextField textByRemovingUselessSpacesFromString:resultString];
    PTKUSAddressZip *addressZIP = [PTKUSAddressZip addressZipWithString:resultString];
    
    // Restrict length
    if (![addressZIP isPartiallyValid]) return NO;
    
    if (replacementString.length > 0) {
        self.zip.text = [addressZIP formattedStringWithTrail];
    } else {
        self.zip.text = [addressZIP formattedString];
    }
    
    // Strip non-digits
    self.zip.text = [addressZIP string];
    
    if ([addressZIP isValid])
        return YES;
    else
        return NO;
}

#pragma mark -
#pragma mark  === DropdownViewDelegate ===
#pragma mark -

- (void)dropdownViewActionForSelectedRow:(int)row sender:(id)sender
{
}

- (void)setupDropdownView:(DropdownView *)dropdownView
{
    [dropdownView refresh];
    [dropdownView setData:@[@"Alabama",@"Alaska",@"Arizona",@"Arkansas",@"California",@"Colorado",@"Connecticut",@"Delaware",@"Florida",@"Georgia",@"Hawaii",@"Idaho",@"Illinois",@"Indiana",@"Iowa",@"Kansas",@"Kentucky",@"Louisiana",@"Maine",@"Maryland",@"Massachusetts",@"Michigan",@"Minnesota",@"Mississippi",@"Misouri",@"Montana",@"Nevada",@"Nebraska",@"New Hampshire",@"New Jersey",@"New Mexico",@"New York",@"North Carolina",@"North Dakota",@"Ohio",@"Ohio",@"Oklahoma",@"Oregon",@"Pennsylvania",@"Rhode Island",@"South Carolina",@"South Dakota",@"Tennessee",@"Texas",@"Utah",@"Vermont",@"Virginia",@"Washington",@"West Virginia",@"Wisconsin",@"Wyoming"]];

    dropdownView.delegate = self;
    dropdownView.listBackgroundColor = [UIColor asaanBackgroundColor];
    dropdownView.titleColor = [UIColor whiteColor];
    dropdownView.enabledTitle = true;
    dropdownView.enabledCheckmark = true;
    [dropdownView setDefaultSelection:12];
}

- (IBAction)addDeliveryAddressClicked:(id)sender
{
    self.savedUserAddress = nil;
    if (IsEmpty(self.streetAddress.text) || IsEmpty(self.city.text) || IsEmpty(self.state.titleLabel.text) || IsEmpty(self.zip.text))
    {
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error" message:@"Please enter all address fields" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    
        [alert show];
        return;
    }
    PTKUSAddressZip *addressZIP = [PTKUSAddressZip addressZipWithString:self.zip.text];
    if (![addressZIP isValid])
    {
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error" message:@"Please enter valid zip" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        [alert show];
        return;
    }
    
    NSString *fullAddress = [[[[[[[self.streetAddress.text stringByAppendingString:@", "] stringByAppendingString:self.city.text]stringByAppendingString:@", "]stringByAppendingString:self.state.titleLabel.text] stringByAppendingString:@" - "] stringByAppendingString:[addressZIP string]] stringByAppendingString:@", USA"];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Please Wait";
    hud.hidden = NO;
    __weak __typeof(self) weakSelf = self;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLServiceUserendpoint *gtlUserService= [appDelegate gtlUserService];

    if (!self.geocoder) self.geocoder = [[CLGeocoder alloc] init];
    [self.geocoder geocodeAddressString:fullAddress completionHandler:^(NSArray* placemarks, NSError* error)
    {
        if (!weakSelf)
            return;
        
        if (!error)
        {
            if (placemarks.count > 1)
            {
                NSString *errMsg = [NSString stringWithFormat:@"Too many locations found matching this address. Please make the address more specific."];
                UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error" message:errMsg delegate:weakSelf cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                
                hud.hidden = YES;
                [alert show];
                return;
            }
            CLPlacemark *placemark = placemarks.firstObject;
            NSString *selectedAddress = ABCreateStringWithAddressDictionary(placemark.addressDictionary, YES);
            NSString *errMsg = [NSString stringWithFormat:@"Savoir matched your given address to %@. Is this correct?", selectedAddress];
            [UIAlertView showWithTitle:@"Address Check" message:errMsg cancelButtonTitle:@"No" otherButtonTitles:@[@"Yes"]
            tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex)
            {
                if (buttonIndex == [alertView cancelButtonIndex])
                {
                    hud.hidden = YES;
                    return;
                }
                else
                {
                    GTLUserendpointUserAddress *userAddress = [[GTLUserendpointUserAddress alloc]init];
                    [userAddress setTitle:self.addressTitle.text];
                    [userAddress setApartment:self.aptNo.text];
                    [userAddress setState:placemark.administrativeArea];
                    [userAddress setCounty:placemark.subAdministrativeArea];
                    [userAddress setCity:placemark.locality];
                    [userAddress setNeighbourhood:placemark.subLocality];
                    [userAddress setStreet:placemark.thoroughfare];
                    [userAddress setStreetNumber:placemark.subThoroughfare];
                    [userAddress setApartment:self.aptNo.text];
                    [userAddress setIsocountryCode:placemark.ISOcountryCode];
                    [userAddress setCountry:placemark.country];
                    [userAddress setZip:placemark.postalCode];
                    [userAddress setNotes:self.other.text];
                    [userAddress setFullAddress:selectedAddress];
                    NSNumber *lat = [NSNumber numberWithDouble:placemark.location.coordinate.latitude];
                    [userAddress setLat:lat];
                    NSNumber *lng = [NSNumber numberWithDouble:placemark.location.coordinate.longitude];
                    [userAddress setLng:lng];
                    
                    GTLQueryUserendpoint *query = [GTLQueryUserendpoint queryForSaveUserAddressWithObject:userAddress];
                    
                    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                    dic[USER_AUTH_TOKEN_HEADER_NAME] = [UtilCalls getAuthTokenForCurrentUser];
                    [query setAdditionalHTTPHeaders:dic];
                    [gtlUserService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error)
                     {
                         hud.hidden = YES;
                         if (!error)
                         {
                             weakSelf.savedUserAddress = object;
                             AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
                             [appDelegate.globalObjectHolder addAddressToUserAddresses:weakSelf.savedUserAddress];
//                             [self.navigationController popViewControllerAnimated:YES];
                             [UtilCalls popFrom:self index:2 Animated:YES];
                        }
                         else
                         {
                             NSString *errMsg = [NSString stringWithFormat:@"%@", [error userInfo][@"error"]];
                             UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Savoir Server Access Failure" message:errMsg delegate:weakSelf cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                             
                             [alert show];
                             return;
                         }
                     }];
                }
            }];
        }
        else
        {
            NSString *errMsg = [NSString stringWithFormat:@"%@", [error userInfo][@"error"]];
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Address not found" message:errMsg delegate:weakSelf cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            
            hud.hidden = YES;
            [alert show];
            return;
        }
    }];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    
    UITextField *next = theTextField.nextTextField;
    if (next) {
        [next becomeFirstResponder];
    } else {
        [self.view endEditing:YES];
    }
    
    if (theTextField == self.other) {
        [self addDeliveryAddressClicked:self];
    }
    
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{
    if ([textField isEqual:self.zip])
    {
        NSString *resultString = [self.zip.text stringByReplacingCharactersInRange:range withString:replacementString];
        resultString = [PTKTextField textByRemovingUselessSpacesFromString:resultString];
        PTKUSAddressZip *addressZIP = [PTKUSAddressZip addressZipWithString:resultString];
        
        // Restrict length
        if (![addressZIP isPartiallyValid]) return NO;
        
        // Strip non-digits
//        self.zip.text = [addressZIP string];
        
        if (![addressZIP isValid])
        {
            if (![addressZIP isPartiallyValid]) return NO;
        }
        else
            return YES;
    }

    return YES;
}

@end
