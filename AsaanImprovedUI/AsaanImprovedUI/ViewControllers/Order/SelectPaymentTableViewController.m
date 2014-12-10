//
//  SelectPaymentTableTableViewController.m
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 12/5/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "SelectPaymentTableViewController.h"
#import "AddPaymentCardViewController.h"
#import "OrderDetailsTableViewController.h"
#import "UIColor+AsaanGoldColor.h"
#import "UIColor+AsaanBackgroundColor.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "PTKCardType.h"
#import "AsaanConstants.h"
#import <Parse/Parse.h>

@interface SelectPaymentTableViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation SelectPaymentTableViewController

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
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor goldColor]};
    
//    [self getUserCards];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {

    if (!self.userCards || !self.userCards.items || self.userCards.items.count == 0) {
        [self performSegueWithIdentifier:@"segueAddPaymentMethod" sender:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.userCards == nil)
        return 1;
    else
        return self.userCards.items.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PaymentCell" forIndexPath:indexPath];
    UIImageView *imgCardType=(UIImageView *)[cell viewWithTag:501];
    UILabel *txtCardLastFour=(UILabel *)[cell viewWithTag:502];
    
    if (self.userCards.items.count == indexPath.row)
    {
        txtCardLastFour.text = @"Add Payment Info";
        imgCardType.image = nil;
    }
    else
    {
        GTLUserendpointUserCard *userCard = [self.userCards.items objectAtIndex:indexPath.row];
        
        imgCardType.image = [UIImage imageNamed:userCard.brand];
        txtCardLastFour.text = userCard.last4;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.userCards.items.count == indexPath.row)
        [self performSegueWithIdentifier:@"segueAddPaymentMethod" sender:self];
    else
    {
        self.savedUserCard = [self.userCards.items objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"segueOrderDetails" sender:self];
    }
}

//- (void) getUserCards
//{
//    typeof(self) weakSelf = self;
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
//    GTLServiceUserendpoint *gtlUserService= [appDelegate gtlUserService];
//    GTLQueryUserendpoint *query = [GTLQueryUserendpoint queryForGetUserCards];
//    
//    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
//    dic[USER_AUTH_TOKEN_HEADER_NAME] = [PFUser currentUser][@"authToken"];
//    [query setAdditionalHTTPHeaders:dic];
//    [gtlUserService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error)
//     {
//         if (!error)
//         {
//             weakSelf.userCards = object;
//             if (weakSelf.userCards.items.count == 0) {
////                 [self performSegueWithIdentifier:@"segueAddPaymentMethod" sender:weakSelf];
//                 NSLog(@"Here should not come");
//             }
//             else
//                 [weakSelf.tableView reloadData];
//         }
//         else
//         {
//             NSString *errMsg = [NSString stringWithFormat:@"%@", [error userInfo]];
//             UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Asaan Server Access Failure" message:errMsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//             
//             [alert show];
//             return;
//         }
//     }];
//}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segueOrderDetails"])
    {
        OrderDetailsTableViewController *controller = [segue destinationViewController];
        [controller setSelectedStore:self.selectedStore];
        [controller setSavedUserAddress:self.savedUserAddress];
        [controller setSavedUserCard:self.savedUserCard];
        [controller setOrderType:self.orderType];
    }
}

- (IBAction)unwindToSelectPaymentMethod:(UIStoryboardSegue *)unwindSegue
{
    NSLog(@"Back to SelectPaymentTableViewController");
//    UIViewController *cc = [unwindSegue sourceViewController];
//    
//    if ([cc isKindOfClass:[AddPaymentCardViewController class]])
//    {
//        AddPaymentCardViewController *controller = (AddPaymentCardViewController *)cc;
//        self.self.savedUserCard = controller.self.savedUserCard;
//        if (![self.self.savedUserCard isKindOfClass:[NSNull class]])
//            [self performSegueWithIdentifier:@"segueOrderDetails" sender:self];
//    }
}

@end
