//
//  ServerSelectGroupTableViewController.h
//  Savoir
//
//  Created by Nirav Saraiya on 4/8/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLStoreendpointStoreOrder.h"
#import "GroupSelectionReceiver.h"

@interface ServerSelectGroupTableViewController : UITableViewController
@property (strong, nonatomic) GTLStoreendpointStoreOrder *selectedOrder;
@property (weak) id <GroupSelectionReceiver> receiver;

@end
