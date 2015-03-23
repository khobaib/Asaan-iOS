//
//  WaitlistTableViewController.m
//  Savoir
//
//  Created by Nirav Saraiya on 2/9/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "WaitlistTableViewController.h"
#import "AppDelegate.h"
#import "GlobalObjectHolder.h"
#import <Parse/Parse.h>
#import "UtilCalls.h"
#import "Constants.h"
#import "GTLStoreendpoint.h"
#import "InlineCalls.h"
#import "Constants.h"

@interface WaitlistTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lbl1_2;
@property (weak, nonatomic) IBOutlet UILabel *lbl3_4;
@property (weak, nonatomic) IBOutlet UILabel *lbl5OrMore;
@property (weak, nonatomic) IBOutlet UILabel *txt1_2;
@property (weak, nonatomic) IBOutlet UILabel *txt3_4;
@property (weak, nonatomic) IBOutlet UILabel *txt5OrMore;
@property (weak, nonatomic) IBOutlet UILabel *txt1_2WaitTime;
@property (weak, nonatomic) IBOutlet UILabel *txt3_4WaitTime;
@property (weak, nonatomic) IBOutlet UILabel *txt5OrMoreWaitTime;
@property (weak, nonatomic) IBOutlet UILabel *partySize;
@property (weak, nonatomic) IBOutlet UILabel *partySizePeopleOrPerson;

@property (nonatomic) int minPartySize;
@property (nonatomic) int currPartySize;
@property (strong, nonatomic) GTLStoreendpointStoreWaitlistSummary *storeWaitListSummary;

@end

@implementation WaitlistTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // NOTE: Rounded rect
    self.lbl1_2.layer.cornerRadius = 10.0f;
    self.lbl1_2.layer.borderWidth = 1.0f;
    self.lbl1_2.layer.borderColor = [UIColor grayColor].CGColor;
    self.lbl3_4.layer.cornerRadius = 10.0f;
    self.lbl3_4.layer.borderWidth = 1.0f;
    self.lbl3_4.layer.borderColor = [UIColor grayColor].CGColor;
    self.lbl5OrMore.layer.cornerRadius = 10.0f;
    self.lbl5OrMore.layer.borderWidth = 1.0f;
    self.lbl5OrMore.layer.borderColor = [UIColor grayColor].CGColor;

    self.minPartySize = self.currPartySize = 1;
    self.partySize.text = [NSString stringWithFormat:@"%d", self.currPartySize];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getStoreWaitTimes];
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil)
    {
        return nil;
    }
    
    // Create label with section title
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(20, 6, 300, 30);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    //    label.shadowColor = [UIColor whiteColor];
    //    label.shadowOffset = CGSizeMake(0.0, 1.0);
    label.font = [UIFont boldSystemFontOfSize:16];
    label.text = sectionTitle;
    
    // Create header view and add label as a subview
    
    // you could also just return the label (instead of making a new view and adding the label as subview. With the view you have more flexibility to make a background color or different paddings
    //    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, SectionHeaderHeight)];
    //    [view addSubview:label];
    
    return label;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)getStoreWaitTimes
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
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
             int partiesOfSize2 = 0;
             int partiesOfSize4 = 0;
             int partiesOfSize5OrMore = 0;
             for (GTLStoreendpointStoreWaitListQueue *entry in object.items)
             {
                 if (entry.partySize.intValue < 3)
                     partiesOfSize2++;
                 else if (entry.partySize.intValue < 5)
                     partiesOfSize4++;
                 else
                     partiesOfSize5OrMore++;
             }
             self.txt1_2.text = [NSString stringWithFormat:@"%d",partiesOfSize2];
             self.txt3_4.text = [NSString stringWithFormat:@"%d",partiesOfSize4];
             self.txt5OrMore.text = [NSString stringWithFormat:@"%d",partiesOfSize5OrMore];
             
             int totalWaitingGroups = partiesOfSize2 + partiesOfSize4 + partiesOfSize5OrMore;
//             if (totalWaitingGroups == 1)
//                 self.totalQueue.text = @"Queue - 1 Party";
//             else
//                 self.totalQueue.text = [NSString stringWithFormat:@"Queue - %d Parties", totalWaitingGroups];
             
             if (totalWaitingGroups == 0)
                 self.txt1_2WaitTime.text = @"15";
             else
                 self.txt1_2WaitTime.text = [NSString stringWithFormat:@"%d-%d", totalWaitingGroups*2 + 15, totalWaitingGroups*2 + 30];
             if (totalWaitingGroups == 0)
                 self.txt3_4WaitTime.text = @"15";
             else
                 self.txt3_4WaitTime.text = [NSString stringWithFormat:@"%d-%d", totalWaitingGroups*2 + 15, totalWaitingGroups*2 + 45];
             if (totalWaitingGroups == 0)
                 self.txt5OrMoreWaitTime.text = @"15";
             else
                 self.txt5OrMoreWaitTime.text = [NSString stringWithFormat:@"%d-%d", totalWaitingGroups*2 + 15, totalWaitingGroups*2 + 30];
             [weakSelf.tableView reloadData];
         }
         else
         {
             NSLog(@"queryForGetStoreWaitListQueueWithStoreId error:%ld, %@", (long)error.code, error.debugDescription);
         }
     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)decPartySize:(id)sender
{
    if (self.currPartySize > self.minPartySize)
        self.partySize.text = [NSString stringWithFormat:@"%d", --self.currPartySize];
}
- (IBAction)incPartySize:(id)sender
{
    self.partySize.text = [NSString stringWithFormat:@"%d", ++self.currPartySize];
}
- (IBAction)getInLine:(id)sender
{
    // Create a new Wait list queue entry for this user and store
    GTLStoreendpointStoreWaitListQueue *newEntry = [[GTLStoreendpointStoreWaitListQueue alloc]init];
    newEntry.storeId = [NSNumber numberWithLongLong:self.selectedStore.identifier.longLongValue];
    newEntry.storeName = self.selectedStore.name;
    int time = (self.storeWaitListSummary.partiesOfSize12.intValue + self.storeWaitListSummary.partiesOfSize34.intValue + self.storeWaitListSummary.partiesOfSize5OrMore.intValue)*2;
    newEntry.estTimeMin = [NSNumber numberWithInt:(time + 15)];
    newEntry.estTimeMax = [NSNumber numberWithInt:(time + 30)];
    newEntry.partySize = [NSNumber numberWithInt:self.currPartySize];
    newEntry.status = [NSNumber numberWithInt:WAITING];
    newEntry.entryFromInternet = [NSNumber numberWithBool:YES];

    __weak __typeof(self) weakSelf = self;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
    GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForSaveStoreWaitlistQueueEntryWithObject:newEntry];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    dic[USER_AUTH_TOKEN_HEADER_NAME] = [UtilCalls getAuthTokenForCurrentUser];
    [query setAdditionalHTTPHeaders:dic];
    
    [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,GTLStoreendpointStoreWaitListQueue *queueEntry,NSError *error)
     {
         if (!error && queueEntry != nil && queueEntry.identifier > 0)
         {
             NSString *title = [NSString stringWithFormat:@"Your Waitlist Entry at %@", weakSelf.selectedStore.name];
             NSString *msg = [NSString stringWithFormat:@"Thank you - your wait list request has been sent. If you need to make changes please call %@ immediately at %@.", weakSelf.selectedStore.name, weakSelf.selectedStore.phone];
             UIAlertView *alert=[[UIAlertView alloc]initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
             [alert show];
             [weakSelf performSegueWithIdentifier:@"segueUnwindWaitlistToStoreList" sender:weakSelf];
         }
         else
         {
             NSLog(@"%@",[error userInfo][@"error"]);
             NSString *title = @"Something went wrong";
             NSString *msg = [NSString stringWithFormat:@"We were unable to reach %@ and place you on their wait list. We're really sorry. Please call %@ directly at %@.", weakSelf.selectedStore.name, weakSelf.selectedStore.name, weakSelf.selectedStore.phone];
             UIAlertView *alert=[[UIAlertView alloc]initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
             [alert show];
         }
     }];
}

@end
