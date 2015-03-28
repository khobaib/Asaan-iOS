//
//  GlobalObjectHolder.h
//  Savoir
//
//  Created by Nirav Saraiya on 12/7/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OnlineOrderDetails.h"
#import "GTLUserendpointUserAddress.h"
#import "GTLUserendpointUserCard.h"
#import "GTLUserendpointUserAddressCollection.h"
#import "GTLUserendpointUserCardCollection.h"
#import "GTLUserendpointUser.h"
#import <CoreLocation/CoreLocation.h>

@interface GlobalObjectHolder : NSObject
@property (strong, nonatomic) OnlineOrderDetails *orderInProgress;
@property (strong, nonatomic) GTLUserendpointUserAddressCollection *userAddresses;
@property (strong, nonatomic) GTLUserendpointUserCardCollection *userCards;
@property (strong, nonatomic) GTLUserendpointUserCard *defaultUserCard;
@property (strong, nonatomic) GTLUserendpointUserAddress *defaultUserAddress;
@property (strong, nonatomic) GTLUserendpointUser *currentUser;
@property (strong, nonatomic) GTLStoreendpointChatRoomsAndStoreChatMemberships *usersRoomsAndStores;
@property (nonatomic) int storeCount;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation* location;

@property (strong, nonatomic) NSString *versionFromServer;

- (OnlineOrderDetails *)createOrderInProgress;
- (void) removeOrderInProgress;

- (void) loadUserAddressesFromServer;
- (void) loadUserCardsFromServer;
- (void) loadCurrentUserFromServer;
- (void) findStoreCountFromServer;

- (void) addCardToUserCards:(GTLUserendpointUserCard *)card;
- (void) addAddressToUserAddresses:(GTLUserendpointUserAddress *)address;

- (void) loadAllUserObjects;
- (void) clearAllObjects;

- (void) loadSupportedClientVersionFromServer;

@end
