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
#import "ChatTabBarController.h"

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

@interface SlidingMenuViewController () {

    NSArray *_menu;
    NSArray *_menuImage;
    NSArray *_menuSegue;
}

@end

@implementation SlidingMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _menu = @[@"Stores", @"Profile", @"Chat History", @"Wait List Status", @"Pending Orders", @"Order History", @"Logout"];
    _menuImage = @[@"stores", @"profile", @"chat_history", @"no_image", @"cart", @"order_history", @"logout"];
    _menuSegue = @[SEGUE_SMToStoreList, SEGUE_SMToUpdateProfile, SEGUE_SMToChatHistory, SEGUE_SMToWaitListStatus, SEGUE_SMToCart, SEGUE_SMToOrderHistory, SEGUE_UnwindToStoreList];
    
    NSAssert(_menu.count == _menuSegue.count, @"Menu and MenuSegue length should be equal.");
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"SMToFriendsSegue"]) {
        AddFriendViewController *vc = (AddFriendViewController *)((UINavigationController *)segue.destinationViewController).topViewController;
        vc.showSlidingMenuButton = true;
    }
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
    
    cell.titleImage.image = [UIImage imageNamed:_menuImage[indexPath.row]];
    cell.titleLabel.text = _menu[indexPath.row];
    cell.badgeRightOffset = 70;
    cell.badgeColor = [UIColor redColor];
    cell.badgeTextColor = [UIColor whiteColor];

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GlobalObjectHolder *goh = appDelegate.globalObjectHolder;
    
    if ([_menuSegue[indexPath.row] isEqualToString:SEGUE_SMToCart])
    {
        if (goh.orderInProgress == nil)
            cell.userInteractionEnabled = cell.titleLabel.enabled = NO;
        else
            cell.userInteractionEnabled = cell.titleLabel.enabled = YES;
    }

    cell.badgeString = @"";
    if ([_menuSegue[indexPath.row] isEqualToString:SEGUE_SMToChatHistory])
        if (appDelegate.notificationUtils.bReceivedChatNotification == true)
            cell.badgeString = @"N";
    
    return cell;
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"Test %@", _menuSegue[indexPath.row]);
    if ([_menuSegue[indexPath.row] isEqualToString:@""])
    {
        return;
    }
    else if ([_menuSegue[indexPath.row] isEqualToString:SEGUE_UnwindToStoreList])
    {
        PFUser *currentUser = [PFUser currentUser];
        if (currentUser)
        {
            [PFUser logOut];
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
            GlobalObjectHolder *goh = appDelegate.globalObjectHolder;
            [goh clearAllObjects];
        }
        
        [self performSegueWithIdentifier:SEGUE_SMToStoreList sender:self];
    }
    else if ([_menuSegue[indexPath.row] isEqualToString:SEGUE_SMToCart])
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        GlobalObjectHolder *goh = appDelegate.globalObjectHolder;
        if (goh.orderInProgress != nil)
            [self performSegueWithIdentifier:_menuSegue[indexPath.row] sender:self];
        else 
            [self.view makeToast:@"No pending order is available."];
    }
    else if ([_menuSegue[indexPath.row] isEqualToString:SEGUE_SMToChatHistory])
    {
        
        SWRevealViewController *revealController = self.revealViewController;
        ChatTabBarController *frontController = [[ChatTabBarController alloc] init];
        frontController.selectedIndex = 0;
        
        [revealController pushFrontViewController:frontController animated:YES];
    }
    else
    {
        [self performSegueWithIdentifier:_menuSegue[indexPath.row] sender:self];
    }
}

@end
