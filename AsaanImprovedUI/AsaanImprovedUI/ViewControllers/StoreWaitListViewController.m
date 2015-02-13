//
//  StoreWaitListViewController.m
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 2/11/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "StoreWaitListViewController.h"
#include "AddToWaitListReceiver.h"
#import "UIColor+AsaanGoldColor.h"
#import "UIColor+AsaanBackgroundColor.h"
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

@interface StoreWaitListViewController ()<UITableViewDataSource, UITableViewDelegate, AddToWaitListReceiver>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnEdit;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnAdd;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSTimer *timer;
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
        [UtilCalls getSlidingMenuBarButtonSetupWith:self];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barTintColor = [UIColor asaanBackgroundColor];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};

    self.allQueueEntries = [[NSMutableArray alloc]init];
    [self loadWaitlistQueue];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [super viewDidAppear:animated];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:90.0 target:self selector:@selector(loadWaitlistQueue) userInfo:nil repeats:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [super viewWillDisappear:animated];
    [self.timer invalidate];
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
                 NSLog(@"queryForGetStoreWaitListQueueWithStoreId error:%ld, %@", error.code, error.debugDescription);
             }
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
    UIImageView *imgProfilePhoto = (UIImageView *)[cell viewWithTag:501];
    UILabel *txtName = (UILabel *)[cell viewWithTag:502];
    UILabel *txtPartySize = (UILabel *)[cell viewWithTag:503];
    UILabel *txtTime = (UILabel *)[cell viewWithTag:504];
    UIButton *tableIsReady = (UIButton *)[cell viewWithTag:505];
    
    tableIsReady.tag = indexPath.row;
    
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
    txtPartySize.text = [NSString stringWithFormat:@"%d",entry.partySize.intValue];
    [tableIsReady addTarget:self action:@selector(tableIsReadyForRow:) forControlEvents:UIControlEventTouchUpInside];
    
    NSCalendar *c = [NSCalendar currentCalendar];
    NSDate *d1 = [NSDate date];
    NSDate *d2 = [NSDate dateWithTimeIntervalSince1970:entry.createdDate.longLongValue/1000];//2012-06-22
    NSDateComponents *components = [c components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:d2 toDate:d1 options:0];
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
    if (self.partiesOfSize2 == 0)
        txt1_2.text = @"None";
    else if (self.partiesOfSize2 == 1)
        txt1_2.text = [NSString stringWithFormat:@"%d party",self.partiesOfSize2];
    else
        txt1_2.text = [NSString stringWithFormat:@"%d parties",self.partiesOfSize2];
    
    if (self.partiesOfSize4 == 0)
        txt3_4.text = @"None";
    else if (self.partiesOfSize4 == 1)
        txt3_4.text = [NSString stringWithFormat:@"%d party",self.partiesOfSize4];
    else
        txt3_4.text = [NSString stringWithFormat:@"%d parties",self.partiesOfSize4];
    
    if (self.partiesOfSize5OrMore == 0)
        txt5OrMore.text = @"None";
    else if (self.partiesOfSize5OrMore == 1)
        txt5OrMore.text = [NSString stringWithFormat:@"%d party",self.partiesOfSize5OrMore];
    else
        txt5OrMore.text = [NSString stringWithFormat:@"%d parties",self.partiesOfSize5OrMore];

    int totalWaitingGroups = self.partiesOfSize2 + self.partiesOfSize4 + self.partiesOfSize5OrMore;
    if (totalWaitingGroups == 1)
        totalQueue.text = @"Queue - 1 Party";
    else
        totalQueue.text = [NSString stringWithFormat:@"Queue - %d Parties", totalWaitingGroups];

    if (totalWaitingGroups == 0)
        txt1_2WaitTime.text = @"15 min or less";
    else
        txt1_2WaitTime.text = [NSString stringWithFormat:@"%d - %d min", totalWaitingGroups*2 + 15, totalWaitingGroups*2 + 30];
    if (totalWaitingGroups == 0)
        txt3_4WaitTime.text = @"15 min";
    else
        txt3_4WaitTime.text = [NSString stringWithFormat:@"%d - %d min", totalWaitingGroups*2 + 15, totalWaitingGroups*2 + 45];
    if (totalWaitingGroups == 0)
        txt5OrMoreWaitTime.text = @"15 min";
    else
        txt5OrMoreWaitTime.text = [NSString stringWithFormat:@"%d - %d min", totalWaitingGroups*2 + 15, totalWaitingGroups*2 + 30];

    return headerCell;
}

- (void) setQueueEntry:(GTLStoreendpointStoreWaitListQueue *)waitListQueueEntry
{
    waitListQueueEntry.storeId = self.selectedStore.identifier;
    waitListQueueEntry.storeName = self.selectedStore.name;
    int time = (self.partiesOfSize2 + self.partiesOfSize4 + self.partiesOfSize5OrMore)*2;
    waitListQueueEntry.estTimeMin = [NSNumber numberWithInt:(time + 15)];
    waitListQueueEntry.estTimeMax = [NSNumber numberWithInt:(time + 30)];
    [self saveQueueEntry:waitListQueueEntry];
    [self.tableView reloadData];
}

#pragma mark - Private Methods
- (IBAction) tableIsReadyForRow:(UIButton *)sender
{
    NSDate *date = [NSDate date];
    long timeInMillis = [date timeIntervalSince1970]*1000;
    
    GTLStoreendpointStoreWaitListQueue *entry = [self.allQueueEntries objectAtIndex:sender.tag];
    entry.dateNotifiedTableIsReady = [NSNumber numberWithLong:timeInMillis];
    
    [self saveQueueEntry:entry];
    NSString *msg = [NSString stringWithFormat:@"Your table at %@ will be ready in a few minutes. Please check in with the host to be seated.", entry.storeName];
    SendPushNotification2(entry.userObjectId, msg);
}

- (void)cancelQueueEntry:(GTLStoreendpointStoreWaitListQueue *)entry
{
    entry.status = [NSNumber numberWithInt:5];
    [self saveQueueEntry:entry];
}

- (void)seatQueueEntry:(GTLStoreendpointStoreWaitListQueue *)entry
{
    entry.status = [NSNumber numberWithInt:3];
    [self saveQueueEntry:entry];
}

- (void)saveQueueEntry:(GTLStoreendpointStoreWaitListQueue *)entry
{
    self.isLoading = YES;
    __weak __typeof(self) weakSelf = self;
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
             [weakSelf.allQueueEntries addObject:queueEntry];
             if (queueEntry.partySize.intValue < 2)
                 weakSelf.partiesOfSize2++;
             else if (queueEntry.partySize.intValue < 4)
                 weakSelf.partiesOfSize4++;
             else
                 weakSelf.partiesOfSize5OrMore++;
             [weakSelf.tableView reloadData];
         }
         else
         {
             NSLog(@"%@",[error userInfo]);
         }
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
