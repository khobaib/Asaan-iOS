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
#import "UIView+Toast.h"

#import "StoreViewController.h"
#import "StoreListTableViewCell.h"
#import "StoreWaitListViewController.h"

#import "ChatView.h"
#import "ChatConstants.h"

#import "MBProgressHUD.h"
#import "ProgressHUD.h"
#import "Constants.h"
#import <CoreLocation/CoreLocation.h>

#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

#import "TablesViewController.h"
#import "ExistingGroupsTableViewController.h"

@interface StoreListTableViewController ()<DataProviderDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) MBProgressHUD *hud;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) int startPosition;
@property (nonatomic) int maxResult;
@property (weak, nonatomic) GTLStoreendpointStoreAndStats *selectedStore;
@property (strong, nonatomic) CLLocation *lastLocation;
@property (nonatomic) NSUInteger distanceFromLastLocation;

- (void)startStandardUpdates;

- (void)showChatRoomForStore:(long long)storeId WithName:(NSString *)storeName;
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [appDelegate.notificationUtils getSlidingMenuBarButtonSetupWith:self];
    
    if ([self isVersionSupported] == false)
    {
        [UIAlertView showWithTitle:@"Savoir update required" message:@"In order to continue please update the Savoir app. It should only take a few moments." cancelButtonTitle:nil otherButtonTitles:@[@"Update"]
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex)
         {
//             if (buttonIndex != [alertView cancelButtonIndex])
//             {
                 NSString *iTunesLink = @"https://itunes.apple.com/us/app/savoir/id967526744?mt=8";
                 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
//             }
          }];
        
        return;
    }
    
    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser)
    {
        [self performSegueWithIdentifier:@"segueStartup" sender:self];
        return;
    }
    else
    {
        BOOL isLinkedToFacebook = [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]];
        if (isLinkedToFacebook == true)
        {
            FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil];
            [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
            {
                if (!error)
                {
                    // handle successful response
                } else if ([[error userInfo][@"error"][@"type"] isEqualToString: @"OAuthException"])
                { // Since the request failed, we can check if it was due to an invalid session
                    NSLog(@"The facebook session was invalidated");
                    [PFFacebookUtils unlinkUserInBackground:[PFUser currentUser]];
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
                    GlobalObjectHolder *goh = appDelegate.globalObjectHolder;
                    [goh clearAllObjects];
                    [self performSegueWithIdentifier:@"segueStartup" sender:self];
                } else
                {
                    NSLog(@"Some other error: %@", error);
                }
            }];
        }
    }
    
//    if (appDelegate.globalObjectHolder.inStoreOrderDetails.selectedStore != nil)
//    {
//        if ([UtilCalls userBelongsToStoreChatTeamForStore:appDelegate.globalObjectHolder.inStoreOrderDetails.selectedStore])
//        {
//            [self startServerMode];
//            return;
//        }
//        else
//        {
//            [self startInStoreMode];
//            return;
//        }
//    }
    
    GlobalObjectHolder *goh = appDelegate.globalObjectHolder;
    [goh loadAllUserObjects];
    if (goh.inStoreOrderDetails == nil && goh.orderInProgress != nil)
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
    
    [self startStandardUpdates];
}

- (Boolean) isVersionSupported
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSString *actualVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *requiredVersion = appDelegate.globalObjectHolder.versionFromServer;
    
    NSLog(@"actualVersion = %@, requiredVersion = %@", actualVersion, requiredVersion);
    
    // This is the simplest way to compare versions, keeping in mind that "1" < "1.0" < "1.0.0"
    if (IsEmpty(requiredVersion) == false && [requiredVersion compare:actualVersion options:NSNumericSearch] == NSOrderedDescending)
        return false;
    else
        return true;
}

- (void) startServerMode
{
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"InStoreServer" bundle:nil];
    MenuTableViewController *destination = [mainStoryBoard instantiateViewControllerWithIdentifier:@"ServerTablesViewController"];
    
    UIStoryboardSegue *segue = [UIStoryboardSegue segueWithIdentifier:@"segueStoreListToServerTableView" source:self destination:destination performHandler:^(void) {
        //view transition/animation
        [self.navigationController pushViewController:destination animated:YES];
    }];
    
    [self shouldPerformSegueWithIdentifier:segue.identifier sender:self];//optional
    [self prepareForSegue:segue sender:self];
    
    [segue perform];

}

- (void) startInStoreMode
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Please Wait";
    hud.hidden = NO;
    
    [appDelegate.globalObjectHolder.inStoreOrderDetails clearCurrentOrder];

    if (self)
    {
        __weak __typeof(self) weakSelf = self;
        GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
        GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForGetStoreTableGroupDetailsForCurrentUser];
        
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
        dic[USER_AUTH_TOKEN_HEADER_NAME]=[UtilCalls getAuthTokenForCurrentUser];
        
        [query setAdditionalHTTPHeaders:dic];
        
        [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLStoreendpointStoreOrderAndTeamDetails *object,NSError *error)
         {
             if(!error)
             {
                 AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
                 appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails = object;
                 NSLog(@"startInStoreMode tableGroupMemberId = %lld orderId = %lld", object.memberMe.identifier.longLongValue, object.order.identifier.longLongValue);
                 if (object != nil && object.memberMe.identifier.longLongValue > 0)
                 {
                     UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"InStorePay" bundle:nil];
                     ExistingGroupsTableViewController *destination = [mainStoryBoard instantiateViewControllerWithIdentifier:@"InstoreOrderSummaryViewController"];
                     
                     UIStoryboardSegue *segue = [UIStoryboardSegue segueWithIdentifier:@"segueStartupToInstoreOrderSummary" source:weakSelf destination:destination performHandler:^(void) {
                         //view transition/animation
                         [weakSelf.navigationController pushViewController:destination animated:YES];
                     }];
                     
                     [weakSelf shouldPerformSegueWithIdentifier:segue.identifier sender:weakSelf];//optional
                     [weakSelf prepareForSegue:segue sender:weakSelf];
                     
                     [segue perform];
                 }
                 else
                 {
                     UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"InStorePay" bundle:nil];
                     ExistingGroupsTableViewController *destination = [mainStoryBoard instantiateViewControllerWithIdentifier:@"ExistingGroupsTableViewController"];
                     
                     UIStoryboardSegue *segue = [UIStoryboardSegue segueWithIdentifier:@"segueStoreListToInStoreExistingGroupView" source:weakSelf destination:destination performHandler:^(void) {
                         //view transition/animation
                         [weakSelf.navigationController pushViewController:destination animated:YES];
                     }];
                     
                     [weakSelf shouldPerformSegueWithIdentifier:segue.identifier sender:weakSelf];//optional
                     [weakSelf prepareForSegue:segue sender:weakSelf];
                     
                     [segue perform];
                 }
             }else{
                 NSLog(@"queryForAddMemberToStoreTableGroup Error:%@",[error userInfo][@"error"]);
             }
             hud.hidden = YES;
         }];
    }
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

- (void)setupDatastore
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    NSInteger pageSize = FluentPagingTablePageSize < appDelegate.globalObjectHolder.storeCount ? FluentPagingTablePageSize : appDelegate.globalObjectHolder.storeCount;
    _dataProvider = [[DataProvider alloc] initWithPageSize:pageSize itemCount:appDelegate.globalObjectHolder.storeCount];
    _dataProvider.delegate = self;
    _dataProvider.shouldLoadAutomatically = YES;
    _dataProvider.automaticPreloadMargin = FluentPagingTablePreloadMargin;
    [self.tableView reloadData];
}

#pragma mark - Data controller delegate
- (void)dataProvider:(DataProvider *)dataProvider didLoadDataAtIndexes:(NSIndexSet *)indexes
{
//    NSMutableArray *indexPathsToReload = [NSMutableArray array];
//    
//    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
//        
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
//        
//        if ([self.tableView.indexPathsForVisibleRows containsObject:indexPath])
//            [indexPathsToReload addObject:indexPath];
//    }];
//    
//    if (indexPathsToReload.count > 0) {
//        [self.tableView reloadRowsAtIndexPaths:indexPathsToReload withRowAnimation:UITableViewRowAnimationFade];
//    }
//    [self.hud hide:YES];
    [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationFade];
}

- (DataLoadingOperation *) getDataLoadingOperationForPage:(NSUInteger)page indexes:(NSIndexSet *)indexes {
    return [[StoreLoadingOperation alloc] initWithIndexes:indexes];
}

- (void)dataProvider:(DataProvider *)dataProvider willLoadDataAtIndexes:(NSIndexSet *)indexes {
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row)
        [self.hud hide:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    StoreListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StoreListCell" forIndexPath:indexPath];
    cell.tag = indexPath.row;
    cell.backgroundColor = [UIColor clearColor];
    
    id dataObject = self.dataProvider.dataObjects[indexPath.row];
    if ([dataObject isKindOfClass:[NSNull class]]) {
        
        cell.callButton.enabled = false;
        cell.chatButton.enabled = false;
        cell.menuButton.enabled = false;
        cell.orderOnlineButton.enabled = false;
        cell.reserveButton.enabled = false;

        [cell.callButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [cell.chatButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [cell.menuButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [cell.orderOnlineButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [cell.reserveButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        
        return cell;
    }
    GTLStoreendpointStoreAndStats *storeAndStats = dataObject;
    if (indexPath.row == 0)
        self.distanceFromLastLocation = storeAndStats.distance.intValue * 1609.34;

    [cell.callButton addTarget:self action:@selector(callStore:) forControlEvents:UIControlEventTouchUpInside];
    [cell.chatButton addTarget:self action:@selector(chatWithStore:) forControlEvents:UIControlEventTouchUpInside];
    [cell.menuButton addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
    [cell.orderOnlineButton addTarget:self action:@selector(placeOrder:) forControlEvents:UIControlEventTouchUpInside];
    [cell.reserveButton addTarget:self action:@selector(reserveTable:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.callButton.enabled = true;
    [cell.callButton setTitleColor:[UIColor goldColor] forState:UIControlStateNormal];
    
    if (storeAndStats.store.claimed.boolValue == true)
    {
        cell.chatButton.enabled = true;
        cell.menuButton.enabled = true;
        [cell.chatButton setTitleColor:[UIColor goldColor] forState:UIControlStateDisabled];
        [cell.menuButton setTitleColor:[UIColor goldColor] forState:UIControlStateDisabled];
        
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
        cell.chatButton.hidden = true;
        cell.menuButton.hidden = true;
        cell.orderOnlineButton.hidden = true;

        [cell.reserveButton setTitle:@"Claim Store" forState:UIControlStateNormal];
        cell.reserveButton.enabled = true;
        [cell.reserveButton setTitleColor:[UIColor goldColor] forState:UIControlStateNormal];
    }
    
//    if (IsEmpty(storeAndStats.store.backgroundImageUrl) == false)
//        [cell.bgImageView sd_setImageWithURL:[NSURL URLWithString:storeAndStats.store.backgroundImageUrl]];
    
    if (IsEmpty(storeAndStats.store.backgroundImageUrl) == false)
    {
        [cell.bgImageView sd_setImageWithURL:[NSURL URLWithString:storeAndStats.store.backgroundImageUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
        {
            if (cacheType == SDImageCacheTypeNone)
            {
                cell.bgImageView.alpha = 0;
                [UIView animateWithDuration:0.3 animations:^{
                    cell.bgImageView.alpha = 1;
                }];
            } else
                cell.bgImageView.alpha = 1;
        }];
    }
    
    cell.restaurantLabel.text = storeAndStats.store.name;
    cell.trophyLabel.text = storeAndStats.store.trophies.firstObject;
//    cell.cuisineLabel.text = [NSString stringWithFormat:@"%@. %@", storeAndStats.store.city, storeAndStats.store.subType];
    cell.cuisineLabel.text = [NSString stringWithFormat:@"%@", storeAndStats.store.city];
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
    NSCharacterSet *doNotWant = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890"] invertedSet];
    NSString *s = [[self.selectedStore.store.phone componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @""];
    NSString *phone = [NSString stringWithFormat:@"telprompt://%@", s];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phone]];
}

- (IBAction)chatWithStore:(UIButton *)sender
{
    _selectedStore = self.dataProvider.dataObjects[sender.tag];
    [self showChatRoomForStore:_selectedStore.store.identifier.longLongValue WithName:_selectedStore.store.name];
}


//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)showChatRoomForStore:(long long)storeId WithName:(NSString *)storeName
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if (storeId == 0)
        return;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLStoreendpointChatRoomsAndStoreChatMemberships *usersRoomsAndStores = appDelegate.globalObjectHolder.usersRoomsAndStores;
    
    for (GTLStoreendpointChatRoom *room in usersRoomsAndStores.chatRooms)
    {
        if (room.storeId.longLongValue == storeId)
        {
            ChatView *chatView = [[ChatView alloc] initWith:room.identifier.longLongValue isStore:false currentStoreId:self.selectedStore.store.identifier.longLongValue];
            chatView.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:chatView animated:YES];
            return;
        }
    }
    
    for (GTLStoreendpointStoreChatTeam *team in usersRoomsAndStores.storeChatMemberships)
    {
        if (team.storeId.longLongValue == storeId)
        {
            ChatView *chatView = [[ChatView alloc] initWith:team.storeId.longLongValue isStore:true currentStoreId:self.selectedStore.store.identifier.longLongValue];
            chatView.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:chatView animated:YES];
            return;
        }
    }
    // Create a new Chat room for this user and store
    GTLStoreendpointChatRoom *newRoom = [[GTLStoreendpointChatRoom alloc]init];
    newRoom.name = storeName;
    newRoom.storeId = [NSNumber numberWithLongLong:storeId];
    __weak __typeof(self) weakSelf = self;
    GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
    GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForSaveChatRoomWithObject:newRoom];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    dic[USER_AUTH_TOKEN_HEADER_NAME] = [UtilCalls getAuthTokenForCurrentUser];
    [query setAdditionalHTTPHeaders:dic];
    
    [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,GTLStoreendpointChatRoom *object,NSError *error)
     {
         if (!error)
         {
             NSMutableArray *newRoomArray = [[NSMutableArray alloc]initWithArray:usersRoomsAndStores.chatRooms];
             [newRoomArray addObject:object];
             usersRoomsAndStores.chatRooms = newRoomArray;
             ChatView *chatView = [[ChatView alloc] initWith:object.identifier.longLongValue isStore:false currentStoreId:self.selectedStore.store.identifier.longLongValue];
//             chatView.hidesBottomBarWhenPushed = YES;
             [weakSelf.navigationController pushViewController:chatView animated:YES];
             return;
         }
         else
             NSLog(@"queryForSaveChatRoomWithObject error:%ld, %@", (long)error.code, error.debugDescription);
     }];
    
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
    NSDate *currentDate = [NSDate date];
    
    if ([UtilCalls canStore:_selectedStore.store fulfillOrderAt:currentDate] == NO)
    {
        NSString *msg = [NSString stringWithFormat:@"%@ is closed and cannot accept any online orders at this time.", _selectedStore.store.name];
        [UIAlertView showWithTitle:@"Online Order Failure" message:msg cancelButtonTitle:@"Ok" otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex)
         {
         }];
    }
    else
        [self performSegueWithIdentifier:@"seguePlaceOnlineOrder" sender:sender];
}

- (IBAction) reserveTable:(UIButton *)sender
{
    _selectedStore = self.dataProvider.dataObjects[sender.tag];
    if (_selectedStore.store.claimed.boolValue == true)
    {
        if ([UtilCalls userBelongsToStoreChatTeamForStore:_selectedStore.store])
            [self performSegueWithIdentifier:@"segueStoreListToStoreWaitList" sender:sender];
        else
            [self performSegueWithIdentifier:@"segueStoreListToReserve" sender:sender];
    }
    else
        [self performSegueWithIdentifier:@"segueStoreListToClaimStore" sender:sender];
}

#pragma mark - Location
- (void)startStandardUpdates
{
    if ([CLLocationManager locationServicesEnabled] == NO || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        NSString *msg = [NSString stringWithFormat:@"Location information is not available."];
        [self.view makeToast:msg];
        
        if (self.lastLocation == nil)
        {
            // 41.772193,-88.15099
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
            if (appDelegate.globalObjectHolder.location == nil)
                self.lastLocation = appDelegate.globalObjectHolder.location = [[CLLocation alloc]initWithLatitude:41.772193 longitude:-88.15099];
            else
                self.lastLocation = appDelegate.globalObjectHolder.location;
            [self setupDatastore];
        }
        return;
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    // Create the location manager if this object does not
    // already have one.
    if (nil == appDelegate.globalObjectHolder.locationManager)
        appDelegate.globalObjectHolder.locationManager = [[CLLocationManager alloc] init];
 
    if ([appDelegate.globalObjectHolder.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
        [appDelegate.globalObjectHolder.locationManager requestAlwaysAuthorization];
    
    appDelegate.globalObjectHolder.locationManager.delegate = self;
    appDelegate.globalObjectHolder.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    
    // Set a movement threshold for new events.
    appDelegate.globalObjectHolder.locationManager.distanceFilter = 50; // meters
    
    [appDelegate.globalObjectHolder.locationManager startUpdatingLocation];
}

- (void)stopStandardUpdates
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [appDelegate.globalObjectHolder.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [manager stopUpdatingLocation];
    NSString *msg = [NSString stringWithFormat:@"Location update failed - error: %@", [error userInfo][@"error"]];
    [self.view makeToast:msg];
    NSLog(@"Location update failed - error: %@", [error userInfo][@"error"]);
    
    if (self.lastLocation == nil)
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        if (appDelegate.globalObjectHolder.location == nil)
            self.lastLocation = appDelegate.globalObjectHolder.location = [[CLLocation alloc]initWithLatitude:41.772193 longitude:-88.15099];
        else
            self.lastLocation = appDelegate.globalObjectHolder.location;
        [self setupDatastore];
    }
}

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [manager stopUpdatingLocation];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    appDelegate.globalObjectHolder.location = [locations lastObject];
    
    if (self.distanceFromLastLocation < 50)
        self.distanceFromLastLocation = 50;
    
    if (self.lastLocation == nil || [self.lastLocation distanceFromLocation:appDelegate.globalObjectHolder.location] > self.distanceFromLastLocation)
    {
        self.lastLocation = appDelegate.globalObjectHolder.location;
        CLLocationCoordinate2D coordinate = [appDelegate.globalObjectHolder.location coordinate];
        
        NSLog(@"Location update received - latitude:%f longitude:%f",coordinate.latitude,coordinate.longitude);
        
        [self setupDatastore];
    }

    //    NSDate* eventDate = location.timestamp;
    //    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    //    if (abs(howRecent) < 15.0)
    //    {
    //        // If the event is recent, do something with it.
    //        NSLog(@"latitude %+.6f, longitude %+.6f\n", location.coordinate.latitude, location.coordinate.longitude);
    //    }
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
