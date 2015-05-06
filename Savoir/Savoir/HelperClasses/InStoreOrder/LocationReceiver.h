//
//  LocationReceiver.h
//  Savoir
//
//  Created by Nirav Saraiya on 5/5/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LocationReceiver <NSObject>
-(void)locationChanged;
@end
