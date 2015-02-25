//
//  StoreListTableTableViewController.m
//  Savoir
//
//  Created by Nirav Saraiya on 11/18/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "StoreListTableViewController.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "GTLStoreendpoint.h"
#import "GTMHTTPFetcher.h"
#import "AppDelegate.h"
#import "InlineCalls.h"
#import "UtilCalls.h"
#import "UIColor+SavoirGoldColor.h"
#import "UIColor+SavoirBackgroundColor.h"
#import "DataProvider.h"
#import "StoreLoadingOperation.h"
#import "UIImageView+WebCache.h"
#import "MenuTableViewController.h"
#import "DeliveryOrCarryoutViewController.h"
#import "ReserveOrWaitlistTableViewController.h"
#import "ClaimStoreViewController.h"
#import "StoreWaitListViewController.h"
#import "UIAlertView+Blocks.h"

#import "StoreViewController.h"
#import "StoreListTableViewCell.h"
#import "StoreWaitListViewController.h"

#import "ChatView.h"
#import "ChatConstants.h"
#import "ChatTabBarController.H"

#import "MBProgressHUD.h"
#import "ProgressHUD.h"
#import "Constants.h"

@interface StoreListTableViewController ()<DataProviderDelegate>

@property (nonatomic, strong) MBProgressHUD *hud;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) int startPosition;
@property (nonatomic) int maxResult;
@property (weak, nonatomic) GTLStoreendpointStoreAndStats *selectedStore;

// Chat Test
@property (strong, nonatomic) UITabBarController *tabBarController;

@end

@implementation StoreListTableViewController
@synthesize tableView = _tableView;
@synthesize startPosition = _startPosition;
@synthesize maxResult = _maxResult;
@synthesize dataProvider = _dataProvider;
@synthesize selectedStore = _selectedStore;

#pragma mark - View Life-cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [UtilCalls getSlidingMenuBarButtonSetupWith:self];
    
    __weak __typeof(self) weakSelf = self;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
    GTLQueryStoreendpoint *query=[GTLQueryStoreendpoint queryForGetStoreCount];
    
    [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,GTLStoreendpointAsaanLong *object,NSError *error)
     {
         NSInteger pageSize = FluentPagingTablePageSize < object.longValue.longLongValue ? FluentPagingTablePageSize : object.longValue.longLongValue;
         _dataProvider = [[DataProvider alloc] initWithPageSize:pageSize itemCount:object.longValue.longLongValue];
         _dataProvider.delegate = weakSelf;
         _dataProvider.shouldLoadAutomatically = YES;
         _dataProvider.automaticPreloadMargin = FluentPagingTablePreloadMargin;
         if ([weakSelf isViewLoaded])
             [weakSelf.tableView reloadData];
     }];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.hud = [MBProgressHUD showHUDAddedTo:_tableView animated:YES];
    [self.hud hide:YES];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser) {
        [self performSegueWithIdentifier:@"segueStartup" sender:self];
        return;
    }
    else{
        
        // Load GAE Objects on startup
        GlobalObjectHolder *objectHolder = appDelegate.globalObjectHolder;
        [objectHolder loadAllUserObjects];
    }
    
    GlobalObjectHolder *goh = appDelegate.globalObjectHolder;
    if (goh.orderInProgress != nil)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"cart.png"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(showOrderSummaryPressed) forControlEvents:UIControlEventTouchUpInside];
        [button setFrame:CGRectMake(0, 0, 25, 25)];
        button.backgroundColor = [UIColor clearColor];
        
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.rightBarButtonItem = item;
    }
    else
        self.navigationItem.rightBarButtonItem = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods
- (void) showOrderSummaryPressed
{
    [self performSegueWithIdentifier:@"segueStoreListToOrderSummary" sender:self];
}

#pragma mark - Data controller delegate
- (void)dataProvider:(DataProvider *)dataProvider didLoadDataAtIndexes:(NSIndexSet *)indexes {
    
    NSMutableArray *indexPathsToReload = [NSMutableArray array];
    
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
        
        if ([self.tableView.indexPathsForVisibleRows containsObject:indexPath]) {
            [indexPathsToReload addObject:indexPath];
        }
    }];
    
    if (indexPathsToReload.count > 0) {
        [self.tableView reloadRowsAtIndexPaths:indexPathsToReload withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.hud hide:YES];
}

- (DataLoadingOperation *) getDataLoadingOperationForPage:(NSUInteger)page indexes:(NSIndexSet *)indexes {
    return [[StoreLoadingOperation alloc] initWithIndexes:indexes];
}

- (void)dataProvider:(DataProvider *)dataProvider willLoadDataAtIndexes:(NSIndexSet *)indexes {
    [self.hud hide:NO];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    StoreListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StoreListCell" forIndexPath:indexPath];
    cell.tag = indexPath.row;
    
    id dataObject = self.dataProvider.dataObjects[indexPath.row];
    if ([dataObject isKindOfClass:[NSNull class]]) {
        
        cell.callButton.enabled = false;
        cell.chatButton.enabled = false;
        cell.menuButton.enabled = false;
        cell.orderOnlineButton.enabled = false;
        cell.reserveButton.enabled = false;
        
        return cell;
    }
    GTLStoreendpointStoreAndStats *storeAndStats = dataObject;

    [cell.callButton addTarget:self action:@selector(callStore:) forControlEvents:UIControlEventTouchUpInside];
    [cell.chatButton addTarget:self action:@selector(chatWithStore:) forControlEvents:UIControlEventTouchUpInside];
    [cell.menuButton addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
    [cell.orderOnlineButton addTarget:self action:@selector(placeOrder:) forControlEvents:UIControlEventTouchUpInside];
    [cell.reserveButton addTarget:self action:@selector(reserveTable:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.callButton.enabled = true;
    
    if (storeAndStats.store.claimed.boolValue == true)
    {
        cell.chatButton.enabled = true;
        cell.menuButton.enabled = true;
        
        cell.chatButton.hidden = false;
        cell.menuButton.hidden = false;
        cell.orderOnlineButton.hidden = false;
        [cell.reserveButton setTitle:@"Reserve" forState:UIControlStateNormal];

        if (storeAndStats.store.providesCarryout.boolValue == true || storeAndStats.store.providesDelivery.boolValue == true || storeAndStats.store.providesPreOrder.boolValue == true)
        {
            cell.orderOnlineButton.enabled = true;
            [cell.orderOnlineButton setTitleColor:[UIColor goldColor] forState:UIControlStateNormal];
        }
        else
        {
            cell.orderOnlineButton.enabled = false;
            [cell.orderOnlineButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        }

        if (storeAndStats.store.providesReservation.boolValue == true || storeAndStats.store.providesWaitlist.boolValue == true)
        {
            cell.reserveButton.enabled = true;
            [cell.reserveButton setTitleColor:[UIColor goldColor] forState:UIControlStateNormal];
        }
        else
        {
            cell.reserveButton.enabled = false;
            [cell.reserveButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        }
    }
    else
    {
        cell.chatButton.enabled = false;
        cell.menuButton.enabled = false;
        cell.orderOnlineButton.enabled = false;

        cell.chatButton.hidden = true;
        cell.menuButton.hidden = true;
        cell.orderOnlineButton.hidden = true;

        [cell.reserveButton setTitle:@"Claim Store" forState:UIControlStateNormal];
    }
    
    if (IsEmpty(storeAndStats.store.backgroundImageUrl) == false)
        [cell.bgImageView sd_setImageWithURL:[NSURL URLWithString:storeAndStats.store.backgroundImageUrl]];
    
    cell.restaurantLabel.text = storeAndStats.store.name;
    cell.trophyLabel.text = storeAndStats.store.trophies.firstObject;
    cell.cuisineLabel.text = [NSString stringWithFormat:@"%@. %@", storeAndStats.store.city, storeAndStats.store.subType];
    if (storeAndStats.stats.visits.longLongValue > 0)
    {
        NSString *strVisitCount = [UtilCalls formattedNumber:storeAndStats.stats.visits];
        NSString *str = [NSString stringWithFormat:@"%@", strVisitCount];
        cell.visitLabel.text = str;
        cell.statsView.hidden = false;
        cell.visitorsImageView.hidden = false;
    }

    NSString *strLike = [UtilCalls getOverallReviewStringFromStats:storeAndStats];
    if (!IsEmpty(strLike))
    {
        cell.likeLabel.text = strLike;
        cell.statsView.hidden = false;
        cell.likesImageView.hidden = false;
    }
    //
    //        if (storeStats.recommendations.longLongValue > 0){
    //            txtRecommends.text = [UtilCalls formattedNumber:storeStats.recommendations];
    //            imgRecommends.hidden = false;
    //        }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataProvider.dataObjects.count;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    _selectedStore = self.dataProvider.dataObjects[indexPath.row];
    if ([_selectedStore isKindOfClass:[NSNull class]]) {
        _selectedStore = nil;
    }
    
    [self performSegueWithIdentifier:@"StoreListToStoreSegue" sender:self];
}

#pragma mark - Actions
- (IBAction) callStore:(UIButton *)sender
{
    _selectedStore = self.dataProvider.dataObjects[sender.tag];
    NSString *number = [NSString stringWithFormat:@"telprompt://%@", self.selectedStore.store.phone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:number]];
}

- (IBAction)chatWithStore:(UIButton *)sender
{
    _selectedStore = self.dataProvider.dataObjects[sender.tag];

    ChatTabBarController *frontController = [[ChatTabBarController alloc] init];
    frontController.parentNavigationController = self.navigationController;
    frontController.selectedStore = self.selectedStore.store;
    
    frontController.selectedIndex = 0;
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self.navigationController pushViewController:frontController animated:YES];
}

- (IBAction) showMenu:(UIButton *)sender
{
    _selectedStore = self.dataProvider.dataObjects[sender.tag];
    [self performSegueWithIdentifier:@"segueMenu" sender:sender];
}

- (IBAction) placeOrder:(UIButton *)sender
{
    _selectedStore = self.dataProvider.dataObjects[sender.tag];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    OnlineOrderDetails *orderInProgress = appDelegate.globalObjectHolder.orderInProgress;
    if (orderInProgress != nil && orderInProgress.selectedStore.identifier.longLongValue != self.selectedStore.store.identifier.longLongValue)
    {
        NSString *errMsg = @"You are starting an order at a new restaurant. Do you want to cancel your other order?";
        [UIAlertView showWithTitle:@"Cancel your order?" message:errMsg cancelButtonTitle:@"No" otherButtonTitles:@[@"Yes"]
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex)
         {
             if (buttonIndex == [alertView cancelButtonIndex])
                 return;
             else
                 [appDelegate.globalObjectHolder removeOrderInProgress];
         }];
    }
    [self performSegueWithIdentifier:@"seguePlaceOnlineOrder" sender:sender];
}

- (IBAction) reserveTable:(UIButton *)sender
{
    _selectedStore = self.dataProvider.dataObjects[sender.tag];
    if (_selectedStore.store.claimed.boolValue == true)
    {
        if ([self userBelongsToStoreChatTeam])
            [self performSegueWithIdentifier:@"segueStoreListToStoreWaitList" sender:sender];
        else
            [self performSegueWithIdentifier:@"segueStoreListToReserve" sender:sender];
    }
    else
        [self performSegueWithIdentifier:@"segueStoreListToClaimStore" sender:sender];
}

-(Boolean)userBelongsToStoreChatTeam
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLStoreendpointStoreChatTeamCollection *teams = appDelegate.globalObjectHolder.usersStoreChatTeamMemberships;
    if (teams == nil)
        return false;
    for (GTLStoreendpointStoreChatTeam *team in teams.items)
        if (team.storeId.longLongValue == self.selectedStore.store.identifier.longLongValue)
            return true;
    return false;
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"segueMenu"])
    {
        // Get reference to the destination view controller
        MenuTableViewController *controller = [segue destinationViewController];
        // Pass any objects to the view controller here, like...
        [controller setSelectedStore:_selectedStore.store];
    }
    else if ([[segue identifier] isEqualToString:@"seguePlaceOnlineOrder"])
    {
        // Get reference to the destination view controller
        DeliveryOrCarryoutViewController *controller = [segue destinationViewController];
        // Pass any objects to the view controller here, like...
        [controller setSelectedStore:_selectedStore.store];
        [controller setBCalledFromStoreList:YES];
    }
    else if ([[segue identifier] isEqualToString:@"StoreListToStoreSegue"]) {
        
        StoreViewController *storeViewController = segue.destinationViewController;
        [storeViewController setSelectedStore:_selectedStore];
    }
    else if ([[segue identifier] isEqualToString:@"segueStoreListToReserve"]) {
        
        ReserveOrWaitlistTableViewController *viewController = segue.destinationViewController;
        [viewController setSelectedStore:_selectedStore.store];
    } //
    else if ([[segue identifier] isEqualToString:@"segueStoreListToStoreWaitList"]) {
        
        StoreWaitListViewController *viewController = segue.destinationViewController;
        [viewController setSelectedStore:_selectedStore.store];
    }
    else if ([[segue identifier] isEqualToString:@"segueStoreListToClaimStore"]) {
        
        ClaimStoreViewController *viewController = segue.destinationViewController;
        viewController.selectedStore = self.selectedStore.store;
    }
}

- (IBAction)unwindToStoreList:(UIStoryboardSegue *)unwindSegue
{
}

@end