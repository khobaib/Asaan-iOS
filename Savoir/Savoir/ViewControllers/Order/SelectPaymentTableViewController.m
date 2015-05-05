//
//  SelectPaymentTableTableViewController.m
//  Savoir
//
//  Created by Nirav Saraiya on 12/5/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "SelectPaymentTableViewController.h"
#import "AddPaymentCardViewController.h"
#import "UIColor+SavoirGoldColor.h"
#import "UIColor+SavoirBackgroundColor.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "PTKCardType.h"
#import "UtilCalls.h"
#import <Parse/Parse.h>

@interface SelectPaymentTableViewController ()

@property (nonatomic, strong) MBProgressHUD *hud;
@property (strong, nonatomic) GTLUserendpointUserCardCollection *userCards;
@end

@implementation SelectPaymentTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    self.userCards = appDelegate.globalObjectHolder.userCards;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableHeaderView = [UtilCalls setupStaticHeaderViewForTable:self.tableView WithTitle:@"Available Payment Options" AndSubTitle:@"Add a new card or select to set default."];
    
//    self.navigationController.toolbarHidden = NO;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    appDelegate.topViewController = self;
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barTintColor = [UIColor asaanBackgroundColor];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    [self.tableView reloadData];
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
    if (self.userCards.items.count == 0)
    {
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = @"Please add a new card.";
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        [messageLabel sizeToFit];
        
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return 0;
    }
    else
    {
        self.tableView.backgroundView = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return self.userCards.items.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PaymentCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    UIImageView *imgCardType=(UIImageView *)[cell viewWithTag:501];
    UILabel *txtCardLastFour=(UILabel *)[cell viewWithTag:502];
    GTLUserendpointUserCard *userCard = [self.userCards.items objectAtIndex:indexPath.row];
    
    imgCardType.image = [UIImage imageNamed:userCard.type];
    txtCardLastFour.text = userCard.last4;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    appDelegate.globalObjectHolder.defaultUserCard = [self.userCards.items objectAtIndex:indexPath.row];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    if ([[segue identifier] isEqualToString:@"segueOrderDetails"])
//    {
//        OrderDetailsTableViewController *controller = [segue destinationViewController];
//        [controller setSelectedStore:self.selectedStore];
//        [controller setSavedUserAddress:self.savedUserAddress];
//        [controller setSavedUserCard:self.savedUserCard];
//        [controller setOrderType:self.orderType];
//    }
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
