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

@implementation GlobalObjectHolder
@synthesize orderInProgress = _orderInProgress;

- (OnlineOrderDetails *)createOrderInProgress {
    
    _orderInProgress = [[OnlineOrderDetails alloc]init];
    _orderInProgress.selectedMenuItems = [[NSMutableArray alloc]init];
    return _orderInProgress;
}

- (void) removeOrderInProgress { _orderInProgress = nil; }

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
