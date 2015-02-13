//
//  GlobalObjectHolder.m
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 12/7/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "GlobalObjectHolder.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "UtilCalls.h"
#import "Constants.h"

@implementation GlobalObjectHolder
@synthesize orderInProgress = _orderInProgress;

- (OnlineOrderDetails *)createOrderInProgress {
    
    _orderInProgress = [[OnlineOrderDetails alloc]init];
    _orderInProgress.selectedMenuItems = [[NSMutableArray alloc]init];
    return _orderInProgress;
}

- (void) clearAllObjects
{
    self.orderInProgress = nil;
    self.userAddresses = nil;
    self.userCards = nil;
    self.defaultUserCard = nil;
    self.defaultUserAddress = nil;
    self.currentUser = nil;
    self.queueEntry = nil;
}

- (void) loadAllUserObjects
{
    if (self.currentUser == nil)
    {
        [self loadCurrentUserFromServer];
        [self loadUserQueueEntry];
        [self loadUserStoreChatTeams];
    }
    if (self.userCards == nil)
        [self loadUserCardsFromServer];
    if (self.userAddresses == nil)
        [self loadUserAddressesFromServer];
}

- (void) removeOrderInProgress { _orderInProgress = nil; }
- (void) removeWaitListQueueEntry
{
    self.queueEntry.status = [NSNumber numberWithInt:4]; // 4 = STATUS_CLOSED_CANCELLED_BY_CUSTOMER
    __weak __typeof(self) weakSelf = self;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
    GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForSaveStoreWaitlistQueueEntryWithObject:self.queueEntry];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    dic[USER_AUTH_TOKEN_HEADER_NAME] = [UtilCalls getAuthTokenForCurrentUser];
    [query setAdditionalHTTPHeaders:dic];
    
    [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,GTLStoreendpointStoreWaitListQueue *queueEntry,NSError *error)
     {
         weakSelf.queueEntry = nil;
         if (error)
         {
             NSLog(@"%@",[error userInfo]);
         }
     }];
}

- (void) loadUserQueueEntry
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
         if (!error)
             weakSelf.queueEntry = object.queueEntry;
         else
             NSLog(@"Asaan Server Call Failed: loadUserQueueEntry - error:%@", error.userInfo);
     }];
}

- (void) loadUserStoreChatTeams
{
    __weak __typeof(self) weakSelf = self;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
    GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForGetStoreChatTeamsForUser];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    dic[USER_AUTH_TOKEN_HEADER_NAME] = [UtilCalls getAuthTokenForCurrentUser];
    [query setAdditionalHTTPHeaders:dic];
    [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLStoreendpointStoreChatTeamCollection *object, NSError *error)
     {
         if (!error)
             weakSelf.usersStoreChatTeamMemberships = object;
         else
             NSLog(@"Asaan Server Call Failed: loadUserStoreChatTeams - error:%@", error.userInfo);
     }];
}

- (void) loadUserAddressesFromServer
{
    __weak __typeof(self) weakSelf = self;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLServiceUserendpoint *gtlUserService= [appDelegate gtlUserService];
    GTLQueryUserendpoint *query = [GTLQueryUserendpoint queryForGetUserAddresses];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    dic[USER_AUTH_TOKEN_HEADER_NAME] = [UtilCalls getAuthTokenForCurrentUser];
    [query setAdditionalHTTPHeaders:dic];
    [gtlUserService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error)
     {
         if (!error)
             weakSelf.userAddresses = object;
         else
             NSLog(@"Asaan Server Call Failed: getUserAddresses - error:%@", error.userInfo);
     }];
}

- (void) loadUserCardsFromServer
{
    __weak __typeof(self) weakSelf = self;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    GTLServiceUserendpoint *gtlUserService= [appDelegate gtlUserService];
    GTLQueryUserendpoint *query = [GTLQueryUserendpoint queryForGetUserCards];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    dic[USER_AUTH_TOKEN_HEADER_NAME] = [UtilCalls getAuthTokenForCurrentUser];
    [query setAdditionalHTTPHeaders:dic];
    [gtlUserService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error)
     {
         if (!error)
         {
             weakSelf.userCards = object;
             for (GTLUserendpointUserCard *object in weakSelf.userCards)
             {
                 if (object.defaultProperty.boolValue == YES)
                 {
                     self.defaultUserCard = object;
                     break;
                 }
             }
             if (self.defaultUserCard == nil && weakSelf.userCards.items.count > 0)
                 self.defaultUserCard = [weakSelf.userCards.items objectAtIndex:0];
         }
         else
         {
             NSLog(@"Asaan Server Call Failed: getUserCards - error:%@", error.userInfo);
         }
     }];
}
- (void) loadCurrentUserFromServer
{
    __weak __typeof(self) weakSelf = self;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    GTLServiceUserendpoint *gtlUserService= [appDelegate gtlUserService];
    GTLQueryUserendpoint *query = [GTLQueryUserendpoint queryForGetCurrentUser];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    dic[USER_AUTH_TOKEN_HEADER_NAME] = [UtilCalls getAuthTokenForCurrentUser];
    [query setAdditionalHTTPHeaders:dic];
    [gtlUserService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLUserendpointUser *object, NSError *error)
     {
         if (!error)
             weakSelf.currentUser = object;
         else
             NSLog(@"Asaan Server Call Failed: getCurrentUser - error:%@", error.userInfo);
     }];
}

- (void) addCardToUserCards:(GTLUserendpointUserCard *)card
{
    NSMutableArray *newCards = [[NSMutableArray alloc]init];//[NSMutableArray arrayWithArray:self.userCards.items];
    for (GTLUserendpointUserCard *object in self.userCards)
        [newCards addObject:object];

    [newCards addObject:card];
    GTLUserendpointUserCardCollection *cards = [[GTLUserendpointUserCardCollection alloc] init];
    cards.items = newCards;
    self.userCards = cards;
    self.defaultUserCard = card;
}

- (void) addAddressToUserAddresses:(GTLUserendpointUserAddress *)address
{
    NSMutableArray *newAddresses = [[NSMutableArray alloc]init];//[NSMutableArray arrayWithArray:self.userAddresses.items];
    for (GTLUserendpointUserAddress *object in self.userAddresses)
        [newAddresses addObject:object];
    [newAddresses addObject:address];
    GTLUserendpointUserAddressCollection *addresses = [[GTLUserendpointUserAddressCollection alloc] init];
    addresses.items = newAddresses;
    self.userAddresses = addresses;
    self.defaultUserAddress = address;
}

@end
