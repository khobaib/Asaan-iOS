//
//  ReserveTableViewController.m
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 2/9/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "ReserveTableViewController.h"
#import "AppDelegate.h"
#import "UtilCalls.h"
#import "pushnotification.h"
#import <Parse/Parse.h>
#import "ChatConstants.h"
#import "UIView+Toast.h"


@interface ReserveTableViewController ()

@property (weak, nonatomic) IBOutlet UILabel *partySize;
@property (weak, nonatomic) IBOutlet UILabel *dayOfWeek;
@property (weak, nonatomic) IBOutlet UILabel *reservationDate;
@property (weak, nonatomic) IBOutlet UILabel *reservationTime;

@property (nonatomic) long minTime;
@property (nonatomic) long timeIncrementInterval;
@property (nonatomic) long timeDecrementInterval;
@property (nonatomic) long dayIncrementInterval;
@property (nonatomic) long dayDecrementInterval;
@property (nonatomic) int minPartySize;
@property (nonatomic) int currPartySize;
@property (nonatomic) NSDate *currTime;

@end

@implementation ReserveTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.selectedStore.name;
    
    self.minPartySize = self.currPartySize = 1;
    self.partySize.text = [NSString stringWithFormat:@"%d", self.currPartySize];
    self.minTime = 7200;
    self.timeIncrementInterval = 900; // 15 min
    self.timeDecrementInterval = -900; // 15 min
    self.dayIncrementInterval = 86400; // 24 hr
    self.dayDecrementInterval = -86400; // 24 hr
    
    NSDate *currentTime = [NSDate date];
    NSDate *minDate = [currentTime dateByAddingTimeInterval:self.minTime];
    self.currTime = minDate;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    self.reservationTime.text = [dateFormatter stringFromDate: self.currTime];
    
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setDateFormat:@"EEEE"];
    self.dayOfWeek.text = [dateFormatter2 stringFromDate:[NSDate date]];
    
    NSDateFormatter *dateFormatter3 = [[NSDateFormatter alloc] init];
    [dateFormatter3 setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter3 setTimeStyle:NSDateFormatterNoStyle];
    self.reservationDate.text = [dateFormatter3 stringFromDate:[NSDate date]];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)decPartySize:(id)sender
{
    if (self.currPartySize > self.minPartySize)
        self.partySize.text = [NSString stringWithFormat:@"%d", --self.currPartySize];
}
- (IBAction)incPartySize:(id)sender
{
    self.partySize.text = [NSString stringWithFormat:@"%d", ++self.currPartySize];
}
- (IBAction)decDay:(id)sender
{
    NSDate *currentTime = [NSDate date];
    NSDate *newTime = [[NSDate alloc] initWithTimeInterval:self.dayDecrementInterval
                                                 sinceDate:self.currTime];
    
    NSDate *minTime = [[NSDate alloc] initWithTimeInterval:self.minTime
                                                 sinceDate:currentTime];
    self.currTime = [newTime laterDate:minTime];
    
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setDateFormat:@"EEEE"];
    self.dayOfWeek.text = [dateFormatter2 stringFromDate:self.currTime];
    
    NSDateFormatter *dateFormatter3 = [[NSDateFormatter alloc] init];
    [dateFormatter3 setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter3 setTimeStyle:NSDateFormatterNoStyle];
    self.reservationDate.text = [dateFormatter3 stringFromDate:self.currTime];
}
- (IBAction)incDay:(id)sender
{
    NSDate *currentTime = [NSDate date];
    NSDate *newTime = [[NSDate alloc] initWithTimeInterval:self.dayIncrementInterval
                                                 sinceDate:self.currTime];
    
    NSDate *minTime = [[NSDate alloc] initWithTimeInterval:self.minTime
                                                 sinceDate:currentTime];
    self.currTime = [newTime laterDate:minTime];
    
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setDateFormat:@"EEEE"];
    self.dayOfWeek.text = [dateFormatter2 stringFromDate:self.currTime];
    
    NSDateFormatter *dateFormatter3 = [[NSDateFormatter alloc] init];
    [dateFormatter3 setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter3 setTimeStyle:NSDateFormatterNoStyle];
    self.reservationDate.text = [dateFormatter3 stringFromDate:self.currTime];
}
- (IBAction)decTime:(id)sender
{
    NSDate *currentTime = [NSDate date];
    NSDate *newTime = [[NSDate alloc] initWithTimeInterval:self.timeDecrementInterval
                                                 sinceDate:self.currTime];
    
    NSDate *minTime = [[NSDate alloc] initWithTimeInterval:self.minTime
                                                      sinceDate:currentTime];
    self.currTime = [newTime laterDate:minTime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    self.reservationTime.text = [dateFormatter stringFromDate: self.currTime];
}
- (IBAction)incTime:(id)sender
{
    NSDate *currentTime = [NSDate date];
    NSDate *newTime = [[NSDate alloc] initWithTimeInterval:self.timeIncrementInterval
                                                 sinceDate:self.currTime];
    
    NSDate *minTime = [[NSDate alloc] initWithTimeInterval:self.minTime
                                                      sinceDate:currentTime];
    self.currTime = [newTime laterDate:minTime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    self.reservationTime.text = [dateFormatter stringFromDate: self.currTime];
}
- (IBAction)sendReservationRequest:(id)sender
{
    [self loadChatRooms];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadChatRooms
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
    GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForGetChatRoomsAndMembershipsForUser];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    dic[USER_AUTH_TOKEN_HEADER_NAME] = [UtilCalls getAuthTokenForCurrentUser];
    [query setAdditionalHTTPHeaders:dic];
    
    [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,GTLStoreendpointChatRoomsAndStoreChatMemberships *object,NSError *error)
     {
         if (!error)
             [self sendMessage:object];
         else
             NSLog(@"queryForGetChatRoomsAndMembershipsForUser error:%ld, %@", error.code, error.debugDescription);
     }];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)sendMessage:(GTLStoreendpointChatRoomsAndStoreChatMemberships *)chatRoomsAndMemberships
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    for (GTLStoreendpointStoreChatTeam *team in chatRoomsAndMemberships.storeChatMemberships)
    {
        if (team.storeId.longLongValue == self.selectedStore.identifier.longLongValue)
        {
            [self.view makeToast:@"Cannot send a reservation note to your own restaurant."];
            return;
        }
    }
    for (GTLStoreendpointChatRoom *room in chatRoomsAndMemberships.chatRooms)
    {
        if (room.storeId.longLongValue == self.selectedStore.identifier.longLongValue)
        {
            [self createMessageAndSend:room.identifier];
            return;
        }
    }
    // Create a new Chat room for this user and store
    GTLStoreendpointChatRoom *newRoom = [[GTLStoreendpointChatRoom alloc]init];
    newRoom.name = self.selectedStore.name;
    newRoom.storeId = [NSNumber numberWithLong:self.selectedStore.identifier.longLongValue];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
    GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForSaveChatRoomWithObject:newRoom];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    dic[USER_AUTH_TOKEN_HEADER_NAME] = [UtilCalls getAuthTokenForCurrentUser];
    [query setAdditionalHTTPHeaders:dic];
    
    [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,GTLStoreendpointChatRoom *room,NSError *error)
     {
         if (!error)
         {
             [self createMessageAndSend:room.identifier];
             return;
         }
         else
             NSLog(@"queryForSaveChatRoomWithObject error:%ld, %@", error.code, error.debugDescription);
     }];
}

- (void)createMessageAndSend:(NSNumber *)roomId
{
    NSString *textMessage = [self createMessageText];
    GTLStoreendpointChatMessage *newMessage = [[GTLStoreendpointChatMessage alloc]init];
    
    newMessage.roomId = roomId;
    
    newMessage.txtMessage = textMessage;
    
    __weak __typeof(self) weakSelf = self;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
    GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForSaveChatMessageWithObject:newMessage];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    dic[USER_AUTH_TOKEN_HEADER_NAME] = [UtilCalls getAuthTokenForCurrentUser];
    [query setAdditionalHTTPHeaders:dic];
    
    [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,GTLStoreendpointChatMessage *object,NSError *error)
     {
         if (error == nil)
         {
             NSString *title = [NSString stringWithFormat:@"Your Reservation - %@", weakSelf.selectedStore.name];
             NSString *msg = [NSString stringWithFormat:@"Thank you - your reservation request has been sent. If you need to make changes please call %@ immediately at %@.", weakSelf.selectedStore.name, weakSelf.selectedStore.phone];
             
             //---------------------------------------------------------------------------------------------------------------------------------------------
             SendPushNotification(roomId.longLongValue, textMessage);
             //---------------------------------------------------------------------------------------------------------------------------------------------

             UIAlertView *alert=[[UIAlertView alloc]initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
             [alert show];
             [weakSelf performSegueWithIdentifier:@"segueUnwindReserveToStoreList" sender:weakSelf];
         }
         else
             NSLog(@"createMessageAndSend queryForSaveChatMessageWithObject error:%ld, %@", error.code, error.debugDescription);
     }];
}

- (NSString *)createMessageText
{
    PFUser *currentUser = [PFUser currentUser];
    NSString *textMessage = [NSString stringWithFormat:@" New Reservation Request: Name: %@ %@. Phone: %@. Party Size: %d. Date:%@ %@. Time:%@.", currentUser[PF_USER_FIRSTNAME], currentUser[PF_USER_LASTNAME], currentUser[PF_USER_PHONE], self.currPartySize, self.dayOfWeek.text, self.reservationDate.text, self.reservationTime.text];

    return textMessage;
}

@end
