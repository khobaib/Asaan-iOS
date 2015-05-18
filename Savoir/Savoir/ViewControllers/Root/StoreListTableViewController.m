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
#import "OrderTypeTableViewController.h"
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

#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

#import "TablesViewController.h"
#import "ExistingGroupsTableViewController.h"
#import "MenuWebViewController.h"
#import "LocationReceiver.h"
#import "LocationManager.h"
#import "YelpUtils.h"

@interface StoreListTableViewController ()<DataProviderDelegate, LocationReceiver, YelpReceiver>

@property (nonatomic, strong) MBProgressHUD *hud;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) int startPosition;
@property (nonatomic) int maxResult;
@property (weak, nonatomic) GTLStoreendpointStoreAndStats *selectedStore;
@property (strong, nonatomic) CLLocation *location;

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

    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(startStandardUpdates) forControlEvents:UIControlEventValueChanged];

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    YelpUtils *yelpUtils = appDelegate.globalObjectHolder.yelpUtils;
    
    [yelpUtils queryBusinessInfoForBusinessId:@"topaz-café-burr-ridge" Receiver:self];
    [yelpUtils queryBusinessInfoForBusinessId:@"wok-n-fire-burr-ridge" Receiver:self];
    [yelpUtils queryBusinessInfoForBusinessId:@"coopers-hawk-winery-and-restaurant-burr-ridge" Receiver:self];
    [yelpUtils queryBusinessInfoForBusinessId:@"capri-ristorante-burr-ridge" Receiver:self];
    [yelpUtils queryBusinessInfoForBusinessId:@"prasino-la-grange-2" Receiver:self];
    [yelpUtils queryBusinessInfoForBusinessId:@"kama-indian-bistro-la-grange-2" Receiver:self];
    [yelpUtils queryBusinessInfoForBusinessId:@"nicksons-eatery-la-grange-2" Receiver:self];
    [yelpUtils queryBusinessInfoForBusinessId:@"tango-naperville" Receiver:self];
    [yelpUtils queryBusinessInfoForBusinessId:@"kumas-asian-bistro-naperville-2" Receiver:self];
    [yelpUtils queryBusinessInfoForBusinessId:@"girl-and-the-goat-chicago" Receiver:self];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)receivedBusinessInfoForBusinessId:(NSString *)businessID Rating:(NSNumber *)rating ReviewCount:(NSNumber *)reviewCount Deals:(NSArray *)deals Error:(NSError *)error;
{
    NSLog(@"%@ %@ %@ %@ %@", businessID, rating, reviewCount, deals, error);
}

- (void)startStandardUpdates
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    if ([appDelegate.globalObjectHolder.locationManager canAccessLocationServices] == YES)
    {
        [appDelegate.globalObjectHolder.locationManager startStandardUpdates:self];
        return;
    }
    
    if ([appDelegate.globalObjectHolder.locationManager shouldAskForLocationAccessPermission] == YES)
    {
        if (self.refreshControl.isRefreshing == true)
            [self.refreshControl endRefreshing];
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Let Savoir Access Your Location even in the background?"
                                      message:@"This lets you find great restaurants near you, open a tab and pay by phone without waiting for a server."
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* give_access = [UIAlertAction
                             actionWithTitle:@"Give Access"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 [appDelegate.globalObjectHolder.locationManager requestAuthorization];
                             }];
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"Not Now"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     appDelegate.globalObjectHolder.locationManager.askedForLocationAccessPermission = [NSDate date];
                                    [alert dismissViewControllerAnimated:YES completion:nil];
                                 }];
        
        [alert addAction:cancel];
        [alert addAction:give_access];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    [self locationChanged];
}

- (void)locationChanged
{
    if (self.refreshControl.isRefreshing == true)
        [self.refreshControl endRefreshing];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if (self.location == nil || [appDelegate.globalObjectHolder.locationManager.lastLocation distanceFromLocation:self.location] > 50)
    {
        self.location = appDelegate.globalObjectHolder.locationManager.lastLocation;
        [self setupDatastore];
    }
    [appDelegate.globalObjectHolder.beaconManager startRegionMonitoring];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    appDelegate.topViewController = self;

    self.navigationController.navigationBarHidden = NO;
    
    [appDelegate.notificationUtils getSlidingMenuBarButtonSetupWith:self];
    
    appDelegate.storeListTableViewController = self;
    if (appDelegate.currentNetworkStatus == NotReachable)
        return;
    appDelegate.storeListTableViewController = nil;
    
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
                    [appDelegate clearAllGlobalObjects];
                    [self performSegueWithIdentifier:@"segueStartup" sender:self];
                    return;
                } else
                {
                    NSLog(@"Some other error: %@", error);
                }
            }];
        }
    }
    
    if ((IsEmpty(currentUser[@"phone"]) == true) ||
         (IsEmpty(currentUser[@"firstName"]) == true && IsEmpty(currentUser[@"lastName"]) == true))
    {
        [self.view makeToast:@"Please complete your profile."];
        [self performSegueWithIdentifier:@"segueStorelistToSignupProfile" sender:self];
        return;
    }
    
    GlobalObjectHolder *goh = appDelegate.globalObjectHolder;
    [goh loadSupportedClientVersionFromServer];
    
    if ([self isVersionSupported] == false)
    {
        [UIAlertView showWithTitle:@"Savoir update required" message:@"In order to continue please update the Savoir app. It should only take a few moments." cancelButtonTitle:nil otherButtonTitles:@[@"Update"]
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex)
         {
             NSString *iTunesLink = @"https://itunes.apple.com/us/app/savoir/id967526744?mt=8";
             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
         }];
        
        return;
    }
    [goh loadAllUserObjects];

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
    if (self.refreshControl.isRefreshing == false)
        [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    if (self)
    {
        __weak __typeof(self) weakSelf = self;
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
        double latInRads = DEG2RAD(appDelegate.globalObjectHolder.locationManager.lastLocation.coordinate.latitude);
        double lngInRads = DEG2RAD(appDelegate.globalObjectHolder.locationManager.lastLocation.coordinate.longitude);
        GTLQueryStoreendpoint *query=[GTLQueryStoreendpoint queryForGetStoresOrderedByDistanceWithStatsWithFirstPosition:0 lat:latInRads lng:lngInRads maxResult:FluentPagingTablePageSize];
        
        [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,GTLStoreendpointStoreAndStatsAndCount *object,NSError *error)
         {
             if(!error)
             {
                 if(object.storeAndStatsList.count > 0)
                 {
                     
                     NSInteger pageSize = FluentPagingTablePageSize < object.storeAndStatsList.count ? FluentPagingTablePageSize : object.storeAndStatsList.count;
                     _dataProvider = [[DataProvider alloc] initWithPageSize:pageSize itemCount:object.storeCount.longValue];
                     _dataProvider.delegate = weakSelf;
                     _dataProvider.shouldLoadAutomatically = YES;
                     _dataProvider.automaticPreloadMargin = FluentPagingTablePreloadMargin;
                     [_dataProvider setInitialObjects:object.storeAndStatsList ForPage:1];
                     [weakSelf.tableView reloadData];
                 }
             }
             else
             {
                 NSString *msg = @"Failed to get restaurant information. Please retry in a few minutes. If this error persists please contact Savoir Customer Assistance team.";
                 [UtilCalls handleGAEServerError:error Message:msg Title:@"Savoir Error" Silent:false];
             }
             if (self.refreshControl.isRefreshing == true)
                 [self.refreshControl endRefreshing];
             else
                 [MBProgressHUD hideAllHUDsForView:self.tableView animated:YES];
         }];
    }
}

#pragma mark - Data controller delegate
- (void)dataProvider:(DataProvider *)dataProvider didLoadDataAtIndexes:(NSIndexSet *)indexes
{
    [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationFade];
}

- (DataLoadingOperation *) getDataLoadingOperationForPage:(NSUInteger)page indexes:(NSIndexSet *)indexes {
    return [[StoreLoadingOperation alloc] initWithIndexes:indexes];
}

- (void)dataProvider:(DataProvider *)dataProvider willLoadDataAtIndexes:(NSIndexSet *)indexes {
    if (self.refreshControl.isRefreshing == false)
        [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row)
    {
        if (self.refreshControl.isRefreshing == true)
            [self.refreshControl endRefreshing];
        else
            [MBProgressHUD hideAllHUDsForView:self.tableView animated:YES];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    StoreListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StoreListCell" forIndexPath:indexPath];
    cell.tag = indexPath.row;
    cell.backgroundColor = [UIColor clearColor];

    cell.chatButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    cell.orderOnlineButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    id dataObject = self.dataProvider.dataObjects[indexPath.row];
    if ([dataObject isKindOfClass:[NSNull class]]) {
        
        cell.callButton.enabled = false;
        cell.chatButton.enabled = false;
        cell.menuButton.enabled = false;
        cell.orderOnlineButton.enabled = false;
        cell.reserveButton.enabled = false;
        cell.statsView.hidden = true;

        [cell.callButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [cell.chatButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [cell.menuButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [cell.orderOnlineButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [cell.reserveButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        
        return cell;
    }
    GTLStoreendpointStoreAndStats *storeAndStats = dataObject;

    [cell.callButton addTarget:self action:@selector(callStore:) forControlEvents:UIControlEventTouchUpInside];
    [cell.chatButton addTarget:self action:@selector(chatWithStore:) forControlEvents:UIControlEventTouchUpInside];
    [cell.menuButton addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
    [cell.orderOnlineButton addTarget:self action:@selector(placeOrder:) forControlEvents:UIControlEventTouchUpInside];
    [cell.reserveButton addTarget:self action:@selector(reserveTable:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.callButton.enabled = true;
    cell.menuButton.enabled = true;
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

        if ((storeAndStats.store.providesCarryout.boolValue == true ||
            storeAndStats.store.providesDelivery.boolValue == true ||
            storeAndStats.store.providesPreOrder.boolValue == true ||
            storeAndStats.store.providesDineInAndPay.boolValue == true) &&
            ([UtilCalls canStore:storeAndStats.store fulfillOrderAt:[NSDate date]] == true))

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
        cell.orderOnlineButton.hidden = true;

        [cell.reserveButton setTitle:@"Claim" forState:UIControlStateNormal];
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
    cell.cuisineLabel.text = [[NSString stringWithFormat:@"%@ \u25C8 %@",storeAndStats.store.subType , storeAndStats.store.city] uppercaseString];
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
//    
//    if (cell.statsView.hidden == true)
//    {
//        CGRect newFrame = cell.statsView.frame;
//        newFrame.size.height = 0;
//        [cell.statsView setFrame:newFrame];
//    }
//    else
//    {
//        CGRect newFrame = cell.statsView.frame;
//        newFrame.size.height = 20;
//        [cell.statsView setFrame:newFrame];
//    }
//    
//    if (IsEmpty(cell.trophyLabel.text))
//    {
//        cell.trophyLabel.hidden = true;
//        CGRect newFrame = cell.statsView.frame;
//        newFrame.size.height = 0;
//        [cell.trophyLabel setFrame:newFrame];
//    }
//    else
//    {
//        cell.trophyLabel.hidden = false;
//        CGRect newFrame = cell.statsView.frame;
//        newFrame.size.height = 20;
//        [cell.trophyLabel setFrame:newFrame];
//    }
    
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
    
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,GTLStoreendpointChatRoom *object,NSError *error)
     {
         if (!error)
         {
             NSMutableArray *newRoomArray = [[NSMutableArray alloc]initWithArray:usersRoomsAndStores.chatRooms];
             [newRoomArray addObject:object];
             usersRoomsAndStores.chatRooms = newRoomArray;
             ChatView *chatView = [[ChatView alloc] initWith:object.identifier.longLongValue isStore:false currentStoreId:self.selectedStore.store.identifier.longLongValue];
             [weakSelf.navigationController pushViewController:chatView animated:YES];
         }
         else
         {
             NSString *msg = @"Failed to save chat room. Please retry in a few minutes. If this error persists please contact Savoir Customer Assistance team.";
             [UtilCalls handleGAEServerError:error Message:msg Title:@"Savoir Error" Silent:false];
         }
         [MBProgressHUD hideAllHUDsForView:self.tableView animated:YES];
     }];
    
}

- (IBAction) showMenu:(UIButton *)sender
{
    _selectedStore = self.dataProvider.dataObjects[sender.tag];
    if (_selectedStore.store.claimed.boolValue == false)
        [self performSegueWithIdentifier:@"segueStorelistToWebMenu" sender:sender];
    else
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
    else if ([[segue identifier] isEqualToString:@"segueStorelistToWebMenu"])
    {
        // Get reference to the destination view controller
        MenuWebViewController *controller = [segue destinationViewController];
        // Pass any objects to the view controller here, like...
//        [controller setMenuURL:@"http://www.topazcafe.com/dinner-menu/"];
        [controller setStoreName:_selectedStore.store.name];
        [controller setMenuURL:_selectedStore.store.twitterUrl];
    }
    else if ([[segue identifier] isEqualToString:@"seguePlaceOnlineOrder"])
    {
        // Get reference to the destination view controller
        OrderTypeTableViewController *controller = [segue destinationViewController];
        // Pass any objects to the view controller here, like...
        [controller setSelectedStore:_selectedStore.store];
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
