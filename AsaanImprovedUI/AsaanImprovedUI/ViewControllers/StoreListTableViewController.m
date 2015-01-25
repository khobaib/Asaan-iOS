//
//  StoreListTableTableViewController.m
//  AsaanImprovedUI
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
#import "UIColor+AsaanGoldColor.h"
#import "UIColor+AsaanBackgroundColor.h"
#import "DataProvider.h"
#import "StoreLoadingOperation.h"
#import "UIImageView+WebCache.h"
#import "MenuTableViewController.h"
#import "DeliveryOrCarryoutViewController.h"
#import "UIAlertView+Blocks.h"

#import "StoreViewController.h"
#import "StoreListTableViewCell.h"
#import "UtilCalls.h"

#import "messages.h"
#import "ChatView.h"
#import "ChatConstants.h"
#import "ChatTabBarController.H"

#import "MBProgressHUD.h"
#import "ProgressHUD.h"

@interface StoreListTableViewController ()<DataProviderDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *revealButtonItem;
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
    [UtilCalls slidingMenuSetupWith:self withItem:self.revealButtonItem];
    
    __weak __typeof(self) weakSelf = self;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
    GTLQueryStoreendpoint *query=[GTLQueryStoreendpoint queryForGetStoreCount];
    
    [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,GTLStoreendpointAsaanLong *object,NSError *error)
     {
         NSInteger pageSize = FluentPagingTablePageSize < object.longValue.longValue ? FluentPagingTablePageSize : object.longValue.longValue;
         _dataProvider = [[DataProvider alloc] initWithPageSize:pageSize itemCount:object.longValue.longValue];
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
        
        if (objectHolder.userCards == nil)
            [objectHolder loadUserCardsFromServer];
        if (objectHolder.userAddresses == nil)
            [objectHolder loadUserAddressesFromServer];
    }
    
//    [self.navigationController setNavigationBarHidden:NO];
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
//                                                  forBarMetrics:UIBarMetricsDefault];
//    self.navigationController.navigationBar.barTintColor = [UIColor asaanBackgroundColor];
//    self.navigationController.navigationBar.shadowImage = [UIImage new];
//    self.navigationController.navigationBar.translucent = NO;
//    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    GlobalObjectHolder *goh = appDelegate.globalObjectHolder;
    if (goh.orderInProgress != nil)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"cart.png"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(showOrderSummaryPressed) forControlEvents:UIControlEventTouchUpInside];
        [button setFrame:CGRectMake(0, 0, 25, 25)];
        button.backgroundColor = [UIColor clearColor];
        
//        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(3, 5, 50, 20)];
//        [label setFont:[UIFont fontWithName:@"Arial-BoldMT" size:13]];
//        [label setText:@"Order"];
//        label.textAlignment = UITextAlignmentCenter;
//        [label setTextColor:[UIColor whiteColor]];
//        [label setBackgroundColor:[UIColor clearColor]];
//        [button addSubview:label];
        
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.rightBarButtonItem = item;
    }
    
    NSNumber *number = [NSNumber numberWithLong:125l];
    
    [self scheduleNotificationWithItem:number interval:10];
}

- (void)scheduleNotificationWithItem:(NSNumber *)item interval:(int)seconds {
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
    NSDate *date = [NSDate date];
    localNotif.fireDate = [date dateByAddingTimeInterval:seconds];
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    localNotif.alertBody = @"How was Kama Bistro?";
    localNotif.alertAction = NSLocalizedString(@"Review", nil);
    
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = 1;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
        localNotif.category = @"REVIEW_CATEGORY";

    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:item forKey:@"REVIEW_ORDER"];
    localNotif.userInfo = infoDict;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
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
    
    [cell.callButton addTarget:self action:@selector(callStore:) forControlEvents:UIControlEventTouchUpInside];
    [cell.chatButton addTarget:self action:@selector(chatWithStore:) forControlEvents:UIControlEventTouchUpInside];
    [cell.menuButton addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
    [cell.orderOnlineButton addTarget:self action:@selector(placeOrder:) forControlEvents:UIControlEventTouchUpInside];
    [cell.reserveButton addTarget:self action:@selector(reserveTable:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.callButton.enabled = true;
    cell.chatButton.enabled = true;
    cell.menuButton.enabled = true;
    cell.orderOnlineButton.enabled = true;
    cell.reserveButton.enabled = true;
    
    GTLStoreendpointStoreAndStats *storeAndStats = dataObject;
    if (storeAndStats != nil)
    {
        if (IsEmpty(storeAndStats.store.backgroundImageUrl) == false)
            [cell.bgImageView sd_setImageWithURL:[NSURL URLWithString:storeAndStats.store.backgroundImageUrl]];
        
        NSLog(@"name = %@, torphy = %@, cuisine = %@", storeAndStats.store.name, storeAndStats.store.trophies.firstObject, storeAndStats.store.subType);
        cell.restaurantLabel.text = storeAndStats.store.name;
        cell.trophyLabel.text = storeAndStats.store.trophies.firstObject;
        cell.cuisineLabel.text = storeAndStats.store.subType;
        if (storeAndStats.stats.visits.longValue > 0)
        {
            NSString *strVisitCount = [UtilCalls formattedNumber:storeAndStats.stats.visits];
            NSString *str = [NSString stringWithFormat:@"Serves: %@+ per Wk", strVisitCount];
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
            
            // Set font, notice the range is for the whole string
            UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
            [attributedString addAttribute:NSFontAttributeName value:font range:NSMakeRange(8, [strVisitCount length]+1)]; // extend larger font to "+" as well
            [cell.visitLabel setAttributedText:attributedString];
            cell.statsView.hidden = false;
        }
        
        long reviewCount = storeAndStats.stats.dislikes.longValue + storeAndStats.stats.likes.longValue;
        if (reviewCount > 0)
        {
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
            int iPercent = (int)(storeAndStats.stats.likes.longValue*100/reviewCount);
            NSNumber *likePercent = [NSNumber numberWithInt:iPercent];
            NSString *strReviews = [UtilCalls formattedNumber:[NSNumber numberWithLong:reviewCount]];
            NSString *strLikePercent = [UtilCalls formattedNumber:likePercent];
            cell.likeLabel.text = [[[strLikePercent stringByAppendingString:@"%("] stringByAppendingString:strReviews] stringByAppendingString:@")"];
            cell.statsView.hidden = false;
        }
        //
        //        if (storeStats.recommendations.longValue > 0){
        //            txtRecommends.text = [UtilCalls formattedNumber:storeStats.recommendations];
        //            imgRecommends.hidden = false;
        //        }
    }
    
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
}

- (void)gotoChatView:(PFObject *)chatroom
{
    NSString *roomId = chatroom.objectId;
    //---------------------------------------------------------------------------------------------------------------------------------------------
    CreateMessageItem([PFUser currentUser], roomId, chatroom[PF_CHATROOMS_NAME]);
    //---------------------------------------------------------------------------------------------------------------------------------------------
    ChatTabBarController *frontController = [[ChatTabBarController alloc] init];
    frontController.parentNavigationController = self.navigationController;
    
    frontController.chatView.roomId = roomId;
    frontController.title = [[chatroom[PF_CHATROOMS_NAME] componentsSeparatedByString:@"$$"] objectAtIndex:0];
    frontController.selectedIndex = 1;
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self.navigationController pushViewController:frontController animated:YES];
//    
//    ChatView *chatView = [[ChatView alloc] initWith:roomId title:[[chatroom[PF_CHATROOMS_NAME] componentsSeparatedByString:@"$$"] objectAtIndex:0]];
//    chatView.hidesBottomBarWhenPushed = YES;
//    
//    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//    [self.navigationController pushViewController:chatView animated:YES];
}

- (void)gotoChatGroup:(NSString *)groupName
{
    NSLog(@"Chat : %@", groupName);
    PFQuery *query = [PFQuery queryWithClassName:PF_CHATROOMS_CLASS_NAME];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         NSLog(@"Chatroom count : %d", objects.count);
         if (error == nil)
         {
             PFObject *chatroom = nil;
             if (objects && objects.count > 0) {
                 for (PFObject *c in objects) {
                     NSLog(@"Chatroom 1 : %@", c[PF_CHATROOMS_NAME]);
                     if ([c[PF_CHATROOMS_NAME] isEqualToString:groupName]) {
                         chatroom = c;
                         break;
                     }
                 }
             }
             
             if (chatroom) {
                 NSLog(@"Chatroom 2 : %@", chatroom);
                 [self gotoChatView:chatroom];
             }
             else {
                 
                 NSLog(@"Chatroom creation : %@", groupName);
                 PFObject *object = [PFObject objectWithClassName:PF_CHATROOMS_CLASS_NAME];
                 object[PF_CHATROOMS_NAME] = groupName;
                 [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                  {
                      if (error == nil)
                      {
                          NSLog(@"Chatroom after creation : %@", groupName);
                          [self gotoChatGroup:groupName];
                      }
                      else {
                          [ProgressHUD showError:@"Network error 2."];
                          
                          [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                      }
                  }];
             }
         }
         else {
             [ProgressHUD showError:@"Network error 1."];
             
             [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
         }
     }];
}

- (IBAction)chatWithStore:(UIButton *)sender
{
    _selectedStore = self.dataProvider.dataObjects[sender.tag];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFUser *user = [PFUser currentUser];
    [self gotoChatGroup:[NSString stringWithFormat:@"%@$$%@$$%@", _selectedStore.store.name, user.objectId, _selectedStore.store.identifier]];
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
    if (orderInProgress != nil && orderInProgress.selectedStore.identifier.longValue != self.selectedStore.store.identifier.longValue)
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
        [storeViewController setSelectedStore:_selectedStore.store];
    }
}

- (IBAction)unwindToStoreList:(UIStoryboardSegue *)unwindSegue
{
}

@end
