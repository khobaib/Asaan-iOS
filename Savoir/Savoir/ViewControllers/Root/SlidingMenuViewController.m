//
//  SlidingMenuViewController.m
//  Savoir
//
//  Created by Hasan Ibna Akbar on 1/4/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "SlidingMenuViewController.h"

#import "AddFriendViewController.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "UIView+Toast.h"
#import "GroupView.h"
#import "UtilCalls.h"

@implementation SMTableViewCell1
@end

#define SEGUE_SMToStoreList         @"SMToStoreListSegue"
#define SEGUE_SMToUpdateProfile     @"SMToUpdateProfile"
#define SEGUE_SMToChatHistory       @"SMToChatHistory"
#define SEGUE_SMToWaitListStatus    @"segueSMToWaitListStatus"
#define SEGUE_SMToFriends           @"SMToFriendsSegue"
#define SEGUE_SMToCart              @"segueSMToOrderSummary"
#define SEGUE_SMToOrderHistory      @"segueSMToOrderHistory"
#define SEGUE_UnwindToStoreList     @"UnwindToStoreList"

#define SEGUE_SMToStoreWaitListInServerMode    @"SMToServerWaitList"
#define SEGUE_SMToStoreDiningInMode    @"FAKE_SMToDiningIn"

@interface SlidingMenuViewController () {

    NSArray *_menu;
    NSArray *_menuImage;
    NSArray *_menuSegue;
}

@end

@implementation SlidingMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
//    appDelegate.topViewController = self;
    
    if (appDelegate.globalObjectHolder.beaconManager.inStoreUtils.isInStore == true &&
        [UtilCalls userBelongsToStoreChatTeamForStore:appDelegate.globalObjectHolder.beaconManager.inStoreUtils.store])
    {
        _menu = @[@"Stores", @"Profile", @"Chat History", @"Wait List", @"Tables", @"Logout"];
        _menuImage = @[@"stores", @"profile", @"chat_history", @"waitlist_table_countdown", @"cart", @"logout"];
        _menuSegue = @[SEGUE_SMToStoreList, SEGUE_SMToUpdateProfile, SEGUE_SMToChatHistory, SEGUE_SMToStoreWaitListInServerMode, SEGUE_SMToStoreDiningInMode, SEGUE_UnwindToStoreList];
        
        NSAssert(_menu.count == _menuSegue.count, @"Menu and MenuSegue length should be equal.");
    }
    else
    {
        _menu = @[@"Stores", @"Profile", @"Chat History", @"Wait List Status", @"Pending Online Order", @"Dining In Order", @"Order History", @"Logout"];
        _menuImage = @[@"stores", @"profile", @"chat_history", @"waitlist_table_countdown", @"cart", @"no_image", @"order_history", @"logout"];
        _menuSegue = @[SEGUE_SMToStoreList, SEGUE_SMToUpdateProfile, SEGUE_SMToChatHistory, SEGUE_SMToWaitListStatus, SEGUE_SMToCart, SEGUE_SMToStoreDiningInMode, SEGUE_SMToOrderHistory, SEGUE_UnwindToStoreList];
        
        NSAssert(_menu.count == _menuSegue.count, @"Menu and MenuSegue length should be equal.");
    }
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
//    if ([segue.identifier isEqualToString:@"SMToFriendsSegue"]) {
//        AddFriendViewController *vc = (AddFriendViewController *)((UINavigationController *)segue.destinationViewController).topViewController;
//        vc.showSlidingMenuButton = true;
//    }
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _menu.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SlidingMenuCell";
    
    SMTableViewCell1 *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier forIndexPath: indexPath];
    cell.backgroundColor = [UIColor clearColor];
    
    cell.titleImage.image = [UIImage imageNamed:_menuImage[indexPath.row]];
    cell.titleLabel.text = _menu[indexPath.row];
    cell.badgeRightOffset = 70;
    cell.badgeColor = [UIColor redColor];
    cell.badgeTextColor = [UIColor whiteColor];
    cell.userInteractionEnabled = cell.titleLabel.enabled = YES;

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GlobalObjectHolder *goh = appDelegate.globalObjectHolder;
    
    if ([_menuSegue[indexPath.row] isEqualToString:SEGUE_SMToCart])
    {
        if (goh.orderInProgress == nil)
            cell.userInteractionEnabled = cell.titleLabel.enabled = NO;
    }
    else if ([_menuSegue[indexPath.row] isEqualToString:SEGUE_SMToStoreDiningInMode])
    {
        cell.userInteractionEnabled = cell.titleLabel.enabled = YES;
        if (appDelegate.globalObjectHolder.beaconManager.inStoreUtils.isInStore == false ||
            ([UtilCalls userBelongsToStoreChatTeamForStore:appDelegate.globalObjectHolder.beaconManager.inStoreUtils.store] == true &&
             appDelegate.globalObjectHolder.inStoreOrderDetails == nil))
            cell.userInteractionEnabled = cell.titleLabel.enabled = NO;
    }

    cell.badgeString = @"";
    if ([_menuSegue[indexPath.row] isEqualToString:SEGUE_SMToChatHistory])
        cell.badgeString = [NSString stringWithFormat:@"%ld", (long)[UIApplication sharedApplication].applicationIconBadgeNumber];
    
    return cell;
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"Test %@", _menuSegue[indexPath.row]);
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if ([_menuSegue[indexPath.row] isEqualToString:@""])
    {
        return;
    }
    else if ([_menuSegue[indexPath.row] isEqualToString:SEGUE_UnwindToStoreList])
    {
        [appDelegate clearAllGlobalObjects];
        
        [self performSegueWithIdentifier:SEGUE_SMToStoreList sender:self];
    }
    else if ([_menuSegue[indexPath.row] isEqualToString:SEGUE_SMToCart])
    {
        GlobalObjectHolder *goh = appDelegate.globalObjectHolder;
        if (goh.orderInProgress != nil)
            [self performSegueWithIdentifier:_menuSegue[indexPath.row] sender:self];
        else 
            [self.view makeToast:@"No pending order is available."];
    }
    else if ([_menuSegue[indexPath.row] isEqualToString:SEGUE_SMToChatHistory])
    {
        
        SWRevealViewController *revealController = self.revealViewController;
        GroupView *groupView = [[GroupView alloc] init];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:groupView];
//        ChatTabBarController *frontController = [[ChatTabBarController alloc] init];
        
        [revealController pushFrontViewController:navController animated:YES];
    }
    else if ([_menuSegue[indexPath.row] isEqualToString:SEGUE_SMToStoreDiningInMode])
    {
        [appDelegate.globalObjectHolder.beaconManager.inStoreUtils startInStoreMode:nil ForStore:appDelegate.globalObjectHolder.beaconManager.inStoreUtils.store InBeaconMode:NO]; //Beaconmode = NO sends control over to new screen.
        [self.revealViewController revealToggleAnimated:YES];
    }
    else
    {
        [self performSegueWithIdentifier:_menuSegue[indexPath.row] sender:self];
    }
}

@end
