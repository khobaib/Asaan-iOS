//
//  GlobalObjectHolder.m
//  Savoir
//
//  Created by Nirav Saraiya on 12/7/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "GlobalObjectHolder.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "UtilCalls.h"
#import "Constants.h"
#import "ChatConstants.h"

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
    self.usersRoomsAndStores = nil;
    self.storesOwnedByUser = nil;
    // Unsubscribe from push notifications by removing the user association from the current installation.
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser)
    {
        [[PFInstallation currentInstallation] removeObjectForKey:PF_INSTALLATION_USER];
        [[PFInstallation currentInstallation] saveInBackground];
        [PFUser logOut];
    }
}

- (void) loadAllUserObjects
{
    PFUser *parseUser = [PFUser currentUser];
    if (parseUser)
    {
        // Load GAE Objects on startup
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        PFUser *user = [currentInstallation objectForKey:@"user"];
        
        if (user == nil || [user.objectId isEqualToString:parseUser.objectId] == false)
        {
            [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:@"user"];
            [[PFInstallation currentInstallation] saveEventually];
        }
        if (self.currentUser == nil)
        {
            [self loadCurrentUserFromServer];
            [self loadUserRoomsAndStoreChatTeams];
            [self getStoresOwnedByUser];
        }
        if (self.userCards == nil)
            [self loadUserCardsFromServer];
        if (self.userAddresses == nil)
            [self loadUserAddressesFromServer];
    }
}

- (void) removeOrderInProgress { _orderInProgress = nil; }

- (void) loadUserRoomsAndStoreChatTeams
{
    __weak __typeof(self) weakSelf = self;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
    GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForGetChatRoomsAndMembershipsForUser];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    dic[USER_AUTH_TOKEN_HEADER_NAME] = [UtilCalls getAuthTokenForCurrentUser];
    [query setAdditionalHTTPHeaders:dic];
    
    [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,GTLStoreendpointChatRoomsAndStoreChatMemberships *object,NSError *error)
     {
         if (!error)
         {
             weakSelf.usersRoomsAndStores = object;
         }
         else
             NSLog(@"queryForGetChatRoomsAndMembershipsForUser error:%ld, %@", (long)error.code, error.debugDescription);
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
             NSLog(@"Savoir Server Call Failed: getUserAddresses - error:%@", error.userInfo);
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
             NSLog(@"Savoir Server Call Failed: getUserCards - error:%@", error.userInfo);
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
             NSLog(@"Savoir Server Call Failed: getCurrentUser - error:%@", error.userInfo);
     }];
}

- (void) findStoreCountFromServer
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSNumber *aNumber = [defaults objectForKey:@"STORE_COUNT"];
    self.storeCount = aNumber.intValue;
    if (self.storeCount == 0 || self.storeCount > 50)
        self.storeCount = 40;
    __weak __typeof(self) weakSelf = self;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
    GTLQueryStoreendpoint *query=[GTLQueryStoreendpoint queryForGetStoreCount];
    
    [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,GTLStoreendpointAsaanLong *object,NSError *error)
     {
         weakSelf.storeCount = object.longValue.intValue;
         [defaults setObject:[NSNumber numberWithLongLong:weakSelf.storeCount] forKey:@"STORE_COUNT"];
         [defaults synchronize];
     }];
}

- (void) loadSupportedClientVersionFromServer
{
    __weak __typeof(self) weakSelf = self;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
    GTLQueryStoreendpoint *query=[GTLQueryStoreendpoint queryForGetClientVersion];
    
    [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,GTLStoreendpointClientVersionMatch *object,NSError *error)
     {
         weakSelf.versionFromServer = object.approvedIOSClientVersion;
     }];
}

- (void) getStoresOwnedByUser
{
    __weak __typeof(self) weakSelf = self;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
    GTLQueryStoreendpoint *query=[GTLQueryStoreendpoint queryForGetStoresOwnedByUser];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    dic[USER_AUTH_TOKEN_HEADER_NAME] = [UtilCalls getAuthTokenForCurrentUser];
    [query setAdditionalHTTPHeaders:dic];
    [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLStoreendpointAsaanLongCollection *object, NSError *error)
     {
         if (!error)
             weakSelf.storesOwnedByUser = object;
         else
             NSLog(@"Savoir Server Call Failed: getStoresOwnedByUser - error:%@", error.userInfo);
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
