//
//  WaitListStatusTableViewController.m
//  AsaanImprovedUI
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


@interface WaitListStatusTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *txtStatus;
@property (weak, nonatomic) IBOutlet UILabel *txtPartiesBefore;
@property (weak, nonatomic) IBOutlet UILabel *txtEstWaitTime;

@end

@implementation WaitListStatusTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [UtilCalls getSlidingMenuBarButtonSetupWith:self];
    [self getStoreWaitStatus];
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
         weakSelf.tableView.tableHeaderView = [UtilCalls setupStaticHeaderViewForTable:self.tableView WithTitle:object.queueEntry.storeName AndSubTitle:@"Your Wait-list Status"];
         if (!error)
         {
             if (object.queueEntry.dateNotifiedTableIsReady.longLongValue > 0)
             {
                 NSString *str = [NSString stringWithFormat:@"Status: Table is ready. Please checkin with the host at %@ to be seated.", object.queueEntry.storeName];
                 NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
                 
                 [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(8, [str length]-8)];
                 [weakSelf.txtStatus setAttributedText:attributedString];
                 weakSelf.txtPartiesBefore.text = [NSString stringWithFormat:@"Parties Ahead of You: %d", 0];
                 weakSelf.txtEstWaitTime.text = [NSString stringWithFormat:@"Estimated Wait Time: %d min", 0];
                 return;
            }
             else if (object.queueEntry.status.intValue == 0)
             {
                 NSString *str = [NSString stringWithFormat:@"Status: Not acknowledged by %@ yet.", object.queueEntry.storeName];
                 NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];

                 // Set font, notice the range is for the whole string
                 [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(8, [str length]-8)];
                 [weakSelf.txtStatus setAttributedText:attributedString];
             }
             else if (object.queueEntry.status.intValue == 1)
             {
                 NSString *str = [NSString stringWithFormat:@"Status: Waiting ..."];
                 NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
                 
                 // Set font, notice the range is for the whole string
                 [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(8, [str length]-8)];
                 [weakSelf.txtStatus setAttributedText:attributedString];
             }
             else if (object.queueEntry.status.intValue == 2)
             {
                 NSString *str = [NSString stringWithFormat:@"Status: Waiting ..."];
                 NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
                 
                 // Set font, notice the range is for the whole string
                 [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor yellowColor] range:NSMakeRange(8, [str length]-8)];
                 [weakSelf.txtStatus setAttributedText:attributedString];
             }
             else
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
             NSDate *d2 = [NSDate dateWithTimeIntervalSince1970:object.queueEntry.createdDate.longLongValue*1000];//2012-06-22
             NSDateComponents *components = [c components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:d2 toDate:d1 options:0];
             NSInteger diff = components.hour*60 + components.minute;
             weakSelf.txtEstWaitTime.text = [NSString stringWithFormat:@"Elapsed Time: %ld min (%d - %d)", diff, (object.queueEntry.estTimeMin.intValue), (object.queueEntry.estTimeMax.intValue)];
         }
         else
             NSLog(@"Asaan Server Call Failed: queryForGetStoreWaitListQueueEntryForCurrentUser - error:%@", error.userInfo);
     }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnLeaveTheLine:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if (appDelegate.globalObjectHolder.queueEntry != nil)
    {
        NSString *errMsg = [NSString stringWithFormat:@"Remove yourself from %@'s wait list?", appDelegate.globalObjectHolder.queueEntry.storeName];
        [UIAlertView showWithTitle:@"Leave your current wait-list?" message:errMsg cancelButtonTitle:@"No" otherButtonTitles:@[@"Yes"]
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex)
         {
             if (buttonIndex == [alertView cancelButtonIndex])
                 return;
             else
             {
                 [appDelegate.globalObjectHolder removeWaitListQueueEntry];
                 [self performSegueWithIdentifier:@"segueunwindWaitListStatusToStoreList" sender:self];
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
