//
//  WaitListStatusTableViewController.m
//  Savoir
//
//  Created by Nirav Saraiya on 2/9/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "WaitListStatusTableViewController.h"
#import "UtilCalls.h"
#import "AppDelegate.h"
#import "GlobalObjectHolder.h"
#import <Parse/Parse.h>
#import "Constants.h"
#import "GTLStoreendpoint.h"
#import "UIAlertView+Blocks.h"
#import "Constants.h"
#import "StoreListTableViewController.h"

@interface WaitListStatusTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *txtStatus;
@property (weak, nonatomic) IBOutlet UILabel *txtPartiesBefore;
@property (weak, nonatomic) IBOutlet UILabel *txtEstWaitTime;
@property (weak, nonatomic) IBOutlet UILabel *txtMsg;
@property (weak, nonatomic) IBOutlet UIButton *btnLeaveLine;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) GTLStoreendpointStoreWaitListQueueAndPosition *queueEntry;

@end

@implementation WaitListStatusTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self getStoreWaitStatus];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [appDelegate.notificationUtils getSlidingMenuBarButtonSetupWith:self];
}
//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [super viewDidAppear:animated];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(getStoreWaitStatus) userInfo:nil repeats:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [super viewWillDisappear:animated];
    [self.timer invalidate];
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
}

- (void) getStoreWaitStatus
{
    __weak __typeof(self) weakSelf = self;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
    GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForGetStoreWaitListQueueEntryForCurrentUser];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    dic[USER_AUTH_TOKEN_HEADER_NAME] = [UtilCalls getAuthTokenForCurrentUser];
    [query setAdditionalHTTPHeaders:dic];
    [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLStoreendpointStoreWaitListQueueAndPosition *object, NSError *error)
     {
         weakSelf.queueEntry = object;
         weakSelf.tableView.tableHeaderView = [UtilCalls setupStaticHeaderViewForTable:self.tableView WithTitle:object.queueEntry.storeName AndSubTitle:@"Your Wait-list Status"];
         if (object.queueEntry == nil)
         {
             weakSelf.txtStatus.text = @"You have not joined any wait-lists.";
             weakSelf.txtPartiesBefore.text = nil;
             weakSelf.txtEstWaitTime.text = nil;
             weakSelf.txtMsg.text = nil;
             weakSelf.btnLeaveLine.hidden = true;
             
             return;
         }
         if (!error)
         {
             if (object.queueEntry.status.intValue == TABLE_IS_READY)
             {
                 NSString *str = [NSString stringWithFormat:@"Status: Table is ready. Please checkin with the host at %@ to be seated.", object.queueEntry.storeName];
                 NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
                 
                 [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(8, [str length]-8)];
                 [weakSelf.txtStatus setAttributedText:attributedString];
                 weakSelf.txtPartiesBefore.text = [NSString stringWithFormat:@"Parties Ahead of You: %d", 0];
                 weakSelf.txtEstWaitTime.text = [NSString stringWithFormat:@"Estimated Wait Time: %d min", 0];
                 return;
            }
             else if (object.queueEntry.status.intValue == WAITING)
             {
                 NSString *str = [NSString stringWithFormat:@"Status: Waiting ..."];
                 NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
                 
                 // Set font, notice the range is for the whole string
                 [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(8, [str length]-8)];
                 [weakSelf.txtStatus setAttributedText:attributedString];
             }
             else if (object.queueEntry.status.intValue == CLOSED_SEATED || object.queueEntry.status.intValue == CLOSED_CANCELLED_BY_CUSTOMER || object.queueEntry.status.intValue == CLOSED_CANCELLED_BY_STORE)
             {
                 NSString *str = [NSString stringWithFormat:@"Status: Closed. Please contact %@ directly for immediate assistance", object.queueEntry.storeName];
                 NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
                 
                 // Set font, notice the range is for the whole string
                 [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(8, [str length]-8)];
                 [weakSelf.txtStatus setAttributedText:attributedString];
                 weakSelf.txtPartiesBefore.text = [NSString stringWithFormat:@"Parties Ahead of You: %d", 0];
                 weakSelf.txtEstWaitTime.text = [NSString stringWithFormat:@"Estimated Wait Time: %d min", 0];
                 return;
             }
             
             weakSelf.txtPartiesBefore.text = [NSString stringWithFormat:@"Parties Ahead of You: %@", object.partiesBeforeEntry];
             NSCalendar *c = [NSCalendar currentCalendar];
             NSDate *d1 = [NSDate date];
             NSDate *d2 = [NSDate dateWithTimeIntervalSince1970:object.queueEntry.createdDate.longLongValue/1000];//2012-06-22
             NSDateComponents *components = [c components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:d2 toDate:d1 options:0];
             NSInteger diff = components.hour*60 + components.minute;
             weakSelf.txtEstWaitTime.text = [NSString stringWithFormat:@"Elapsed Time: %ld min (%d - %d)", (long)diff, (object.queueEntry.estTimeMin.intValue), (object.queueEntry.estTimeMax.intValue)];
         }
         else
             NSLog(@"Savoir Server Call Failed: queryForGetStoreWaitListQueueEntryForCurrentUser - error:%@", error.userInfo);
     }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnLeaveTheLine:(id)sender
{
    if (self.queueEntry != nil)
    {
        NSString *errMsg = [NSString stringWithFormat:@"Remove yourself from %@'s wait list?", self.queueEntry.queueEntry.storeName];
        [UIAlertView showWithTitle:@"Leave your current wait-list?" message:errMsg cancelButtonTitle:@"No" otherButtonTitles:@[@"Yes"]
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex)
         {
             if (buttonIndex == [alertView cancelButtonIndex])
                 return;
             else
             {
                 [UtilCalls removeWaitListQueueEntry:self.queueEntry.queueEntry];
                 [self performSegueWithIdentifier:@"SWWaitListStatusToStoreList" sender:self];
             }
         }];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
