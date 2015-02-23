//
//  PhoneSearchReceiver.h
//  Savoir
//
//  Created by Nirav Saraiya on 2/11/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTLUserendpointChatUser.h"

@protocol PhoneSearchReceiver <NSObject>
- (void) setChatUser:(GTLUserendpointChatUser *)chatUser;
@end
