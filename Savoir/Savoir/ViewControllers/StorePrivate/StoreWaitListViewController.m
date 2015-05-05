//
//  StoreWaitListViewController.m
//  Savoir
//
//  Created by Nirav Saraiya on 2/11/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "StoreWaitListViewController.h"
#include "AddToWaitListReceiver.h"
#import "UIColor+SavoirGoldColor.h"
#import "UIColor+SavoirBackgroundColor.h"
#import "AppDelegate.h"
#import "UtilCalls.h"
#import "PhoneSearchViewController.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "InlineCalls.h"
#import "Extension.h"
#import "UIAlertView+Blocks.h"
#import "UIView+Toast.h"
#import "pushnotification.h"
#import "AddToWaitListViewController.h"
#import "Constants.h"
#import "UIView+Superview.h"
#import "MBProgressHUD.h"


@interface StoreWaitListViewController ()<UITableViewDataSource, UITableViewDelegate, AddToWaitListReceiver>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnEdit;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnAdd;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (nonatomic) BOOL isLoading;
@property (nonatomic) int partiesOfSize2;
@property (nonatomic) int partiesOfSize4;
@property (nonatomic) int partiesOfSize5OrMore;
@property (strong, nonatomic) NSMutableArray *allQueueEntries;

@end

@implementation StoreWaitListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (self.navigationController.viewControllers[0] != self)
        self.navigationItem.leftBarButtonItem = nil;
    else
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        [appDelegate.notificationUtils getSlidingMenuBarButtonSetupWith:self];
    }
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barTintColor = [UIColor asaanBackgroundColor];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    NSString *title = [NSString stringWithFormat:@"%@ Wait List", self.selectedStore.name];
    self.navigationItem.title = title;

    self.allQueueEntries = [[NSMutableArray alloc]init];
    [self loadWaitlistQueue];
    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    //    self.refreshControl.backgroundColor = [UIColor goldColor];
    //    self.refreshControl.tintColor = [UIColor blackColor];
    [self.refreshControl addTarget:self action:@selector(loadWaitlistQueue) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    appDelegate.topViewController = self;
}
//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Backend methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadWaitlistQueue
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if (self.isLoading == NO)
    {
        self.isLoading = YES;

        if (self.refreshControl.isRefreshing == false)
            [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
       
        __weak __typeof(self) weakSelf = self;
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
        GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForGetStoreWaitListQueueWithStoreId:self.selectedStore.identifier.longLongValue];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        dic[USER_AUTH_TOKEN_HEADER_NAME] = [UtilCalls getAuthTokenForCurrentUser];
        [query setAdditionalHTTPHeaders:dic];
        
        [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,GTLStoreendpointStoreWaitListQueueCollection *object,NSError *error)
         {
             if (!error)
             {
                 [weakSelf.allQueueEntries removeAllObjects];
                 weakSelf.partiesOfSize2 = 0;
                 weakSelf.partiesOfSize4 = 0;
                 weakSelf.partiesOfSize5OrMore = 0;
                 for (GTLStoreendpointStoreWaitListQueue *entry in object.items)
                 {
                     if (entry.partySize.intValue < 3)
                         weakSelf.partiesOfSize2++;
                     else if (entry.partySize.intValue < 5)
                         weakSelf.partiesOfSize4++;
                     else
                         weakSelf.partiesOfSize5OrMore++;

                     [weakSelf.allQueueEntries addObject:entry];
                 }
                 [weakSelf.tableView reloadData];
             }
             else
             {
                 NSString *msg = [NSString stringWithFormat:@"Failed to obtain wait-list information. Please retry in a few minutes. If this error persists please contact Savoir Customer Assistance team. Error: %@", [error userInfo][@"error"]];
                 [[[UIAlertView alloc]initWithTitle:@"Error" message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                 NSLog(@"queryForGetStoreWaitListQueueWithStoreId error:%ld, %@", (long)error.code, error.debugDescription);
             }
             if (self.refreshControl.isRefreshing == true)
                 [self.refreshControl endRefreshing];
             else
                 [MBProgressHUD hideAllHUDsForView:self.tableView animated:YES];
             self.isLoading = NO;
         }];
    }
}

- (IBAction)btnEdit:(id)sender
{
    if (self.btnEdit.tag == 0) // start editing
    {
        [self setEditing:YES animated:YES];
        self.btnEdit.title = @"Done";
        self.btnEdit.tag = 1;
        self.btnAdd.enabled = NO;
    }
    else
    {
        [self setEditing:NO animated:YES];
        self.btnEdit.title = @"Edit";
        self.btnEdit.tag = 0;
        self.btnAdd.enabled = YES;
    }
}
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:YES];
}
#pragma mark -
#pragma mark  === UITableViewDataSource ===
#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allQueueEntries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    UIImageView *imgProfilePhoto = (UIImageView *)[cell viewWithTag:501];
    UILabel *txtName = (UILabel *)[cell viewWithTag:502];
    UILabel *txtPartySize = (UILabel *)[cell viewWithTag:503];
    UILabel *txtTime = (UILabel *)[cell viewWithTag:504];
    UIButton *btnTableIsReady = (UIButton *)[cell viewWithTag:506];
    UIButton *btnJoinedFromInternet = (UIButton *)[cell viewWithTag:505];
    
    btnTableIsReady.imageView.image = nil;
    
    cell.tag = indexPath.row;
    
    // NOTE: Rounded rect
    imgProfilePhoto.layer.cornerRadius = 10.0f;
    imgProfilePhoto.clipsToBounds = YES;
    //    imgProfilePhoto.layer.borderWidth = 1.0f;
    //    imgProfilePhoto.layer.borderColor = [UIColor grayColor].CGColor;
    
    GTLStoreendpointStoreWaitListQueue *entry = [self.allQueueEntries objectAtIndex:indexPath.row];
    
    if (IsEmpty(entry.userProfilePhotoUrl) == false && ![entry.userProfilePhotoUrl isEqualToString:@"undefined"])
    {
        //        [cell.itemPFImageView sd_setImageWithURL:[NSURL URLWithString:menuItemAndStats.menuItem.thumbnailUrl]];
        [imgProfilePhoto setImageWithURL:[NSURL URLWithString:entry.userProfilePhotoUrl ]
                        placeholderImage:[UIImage imageWithColor:RGBA(0.0, 0.0, 0.0, 0.5)]
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                   if (error) {
                                       NSLog(@"ERROR : %@", error);
                                   }
                               }
             usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    else {
        imgProfilePhoto.image = [UIImage imageNamed:@"no_image"];
    }
    
    txtName.text = entry.userName;
    if (entry.partySize.intValue == 1)
        txtPartySize.text = [NSString stringWithFormat:@"%d person",entry.partySize.intValue];
    else
        txtPartySize.text = [NSString stringWithFormat:@"%d people",entry.partySize.intValue];

    if (entry.status.intValue == TABLE_IS_READY)
        btnTableIsReady.imageView.image = [UIImage imageNamed:@"waitlist_table_ready"];
    else if (entry.status.intValue == CLOSED_SEATED)
        btnTableIsReady.imageView.image = [UIImage imageNamed:@"waitlist_table_seated"];
    else if (entry.status.intValue == WAITING)
        btnTableIsReady.imageView.image = [UIImage imageNamed:@"waitlist_table_countdown"];

    [btnTableIsReady addTarget:self action:@selector(tableIsReadyButtonPressed:) forControlEvents:UIControlEventTouchDown];
    
    [btnJoinedFromInternet addTarget:self action:@selector(tableIsReadyButtonPressed:) forControlEvents:UIControlEventTouchDown];
    
    if (entry.entryFromInternet.boolValue == true)
        btnJoinedFromInternet.imageView.image = [UIImage imageNamed:@"waitlist_joined_by_internet"];
    else
        btnJoinedFromInternet.imageView.image = nil;
    
    NSCalendar *c = [NSCalendar currentCalendar];
    NSDate *d1 = [NSDate date];
    NSDate *d2 = [NSDate dateWithTimeIntervalSince1970:entry.createdDate.longLongValue/1000];//2012-06-22
    NSDateComponents *components = [c components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:d2 toDate:d1 options:0];
    NSInteger diff = components.hour*60 + components.minute;
    
    txtTime.text = [NSString stringWithFormat:@"%d-%d(%ld)", entry.estTimeMin.intValue, entry.estTimeMax.intValue, (long)diff];
    if (diff < entry.estTimeMin.intValue)
        txtTime.textColor = [UIColor greenColor];
    else if (diff > entry.estTimeMax.intValue)
        txtTime.textColor = [UIColor redColor];
    else
        txtTime.textColor = [UIColor yellowColor];
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.allQueueEntries.count > indexPath.row)
        return UITableViewCellEditingStyleDelete;
    else
        return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        GTLStoreendpointStoreWaitListQueue *entry = [self.allQueueEntries objectAtIndex:indexPath.row];
        [self cancelQueueEntry:entry];
        [self.allQueueEntries removeObjectAtIndex:indexPath.row];
        //        if (self.orderInProgress.selectedMenuItems.count > 0)
        //            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        //        else
        [tableView reloadData];
    }
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewCell *headerCell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
    UILabel *lbl1_2 = (UILabel *)[headerCell viewWithTag:508];
    UILabel *lbl3_4 = (UILabel *)[headerCell viewWithTag:509];
    UILabel *lbl5OrMore = (UILabel *)[headerCell viewWithTag:510];
    UILabel *txt1_2 = (UILabel *)[headerCell viewWithTag:501];
    UILabel *txt3_4 = (UILabel *)[headerCell viewWithTag:502];
    UILabel *txt5OrMore = (UILabel *)[headerCell viewWithTag:503];
    UILabel *txt1_2WaitTime = (UILabel *)[headerCell viewWithTag:504];
    UILabel *txt3_4WaitTime = (UILabel *)[headerCell viewWithTag:505];
    UILabel *txt5OrMoreWaitTime = (UILabel *)[headerCell viewWithTag:506];
    UILabel *totalQueue = (UILabel *)[headerCell viewWithTag:507];
    
    // NOTE: Rounded rect
    lbl1_2.layer.cornerRadius = 10.0f;
    lbl1_2.layer.borderWidth = 1.0f;
    lbl1_2.layer.borderColor = [UIColor grayColor].CGColor;
    lbl3_4.layer.cornerRadius = 10.0f;
    lbl3_4.layer.borderWidth = 1.0f;
    lbl3_4.layer.borderColor = [UIColor grayColor].CGColor;
    lbl5OrMore.layer.cornerRadius = 10.0f;
    lbl5OrMore.layer.borderWidth = 1.0f;
    lbl5OrMore.layer.borderColor = [UIColor grayColor].CGColor;
    
    txt1_2.text = [NSString stringWithFormat:@"%d",self.partiesOfSize2];
    txt3_4.text = [NSString stringWithFormat:@"%d",self.partiesOfSize4];
    txt5OrMore.text = [NSString stringWithFormat:@"%d",self.partiesOfSize5OrMore];

    int totalWaitingGroups = self.partiesOfSize2 + self.partiesOfSize4 + self.partiesOfSize5OrMore;
    if (totalWaitingGroups == 1)
        totalQueue.text = @"Queue - 1 Party";
    else
        totalQueue.text = [NSString stringWithFormat:@"Queue - %d Parties", totalWaitingGroups];

    if (totalWaitingGroups == 0)
        txt1_2WaitTime.text = @"0-15min";
    else
        txt1_2WaitTime.text = [NSString stringWithFormat:@"%d-%d", totalWaitingGroups*2 + 15, totalWaitingGroups*2 + 30];
    if (totalWaitingGroups == 0)
        txt3_4WaitTime.text = @"15";
    else
        txt3_4WaitTime.text = [NSString stringWithFormat:@"%d-%d", totalWaitingGroups*2 + 15, totalWaitingGroups*2 + 45];
    if (totalWaitingGroups == 0)
        txt5OrMoreWaitTime.text = @"15";
    else
        txt5OrMoreWaitTime.text = [NSString stringWithFormat:@"%d-%d", totalWaitingGroups*2 + 15, totalWaitingGroups*2 + 30];

    return headerCell;
}

- (void) setQueueEntry:(GTLStoreendpointStoreWaitListQueue *)waitListQueueEntry
{
    waitListQueueEntry.storeId = self.selectedStore.identifier;
    waitListQueueEntry.storeName = self.selectedStore.name;
    int time = (self.partiesOfSize2 + self.partiesOfSize4 + self.partiesOfSize5OrMore)*2;
    waitListQueueEntry.estTimeMin = [NSNumber numberWithInt:(time + 15)];
    waitListQueueEntry.estTimeMax = [NSNumber numberWithInt:(time + 30)];
    waitListQueueEntry.entryFromInternet = [NSNumber numberWithBool:NO];
    [self saveQueueEntry:waitListQueueEntry];
    [self.tableView reloadData];
}

#pragma mark - Private Methods

-(void)tableIsReadyButtonPressed:(UIButton *)btnTableIsReady
{
    UIView *cell = [btnTableIsReady findSuperViewWithClass:[UITableViewCell class]];
    GTLStoreendpointStoreWaitListQueue *entry = [self.allQueueEntries objectAtIndex:cell.tag];
    
    if (entry.status.intValue == TABLE_IS_READY)
    {
        btnTableIsReady.imageView.image = [UIImage imageNamed:@"waitlist_table_seated"];
        [btnTableIsReady.imageView setNeedsDisplay];
        [self seatQueueEntry:entry];
    }
    else
    {
        btnTableIsReady.imageView.image = [UIImage imageNamed:@"waitlist_table_ready"];
        [btnTableIsReady.imageView setNeedsDisplay];
        NSDate *date = [NSDate date];
        long timeInMillis = [date timeIntervalSince1970]*1000;
        
        entry.dateNotifiedTableIsReady = [NSNumber numberWithLong:timeInMillis];
        
        entry.status = [NSNumber numberWithInt:TABLE_IS_READY];
        [self saveQueueEntry:entry];
    }
}

- (void)cancelQueueEntry:(GTLStoreendpointStoreWaitListQueue *)entry
{
    entry.status = [NSNumber numberWithInt:CLOSED_CANCELLED_BY_STORE];
    [self saveQueueEntry:entry];
}

- (void)seatQueueEntry:(GTLStoreendpointStoreWaitListQueue *)entry
{
    entry.status = [NSNumber numberWithInt:CLOSED_SEATED];
    [self saveQueueEntry:entry];
}

- (void)saveQueueEntry:(GTLStoreendpointStoreWaitListQueue *)entry
{
    self.isLoading = YES;
    __weak __typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
    GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForSaveStoreWaitlistQueueEntryByStoreEmployeeWithObject:entry queuePosition:self.allQueueEntries.count+1];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    dic[USER_AUTH_TOKEN_HEADER_NAME] = [UtilCalls getAuthTokenForCurrentUser];
    [query setAdditionalHTTPHeaders:dic];
    
    [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,GTLStoreendpointStoreWaitListQueue *queueEntry,NSError *error)
     {
         if (!error && queueEntry != nil && queueEntry.identifier.longLongValue > 0)
         {
             if (queueEntry.status.intValue == WAITING)
             {
                 [weakSelf.allQueueEntries addObject:queueEntry];
                 if (queueEntry.partySize.intValue < 2)
                     weakSelf.partiesOfSize2++;
                 else if (queueEntry.partySize.intValue < 4)
                     weakSelf.partiesOfSize4++;
                 else
                     weakSelf.partiesOfSize5OrMore++;
             }
             [weakSelf.tableView reloadData];
         }
         else
         {
             NSLog(@"%@",[error userInfo][@"error"]);
         }
         [MBProgressHUD hideAllHUDsForView:self.tableView animated:YES];
         self.isLoading = NO;
     }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segueWaitListToAddToWaitList"])
    {
        AddToWaitListViewController *viewController = segue.destinationViewController;
        viewController.receiver = self;
    }
}

@end
