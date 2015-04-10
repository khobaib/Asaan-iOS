//
//  JoinGroupTableViewController.h
//  Savoir
//
//  Created by Nirav Saraiya on 4/5/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLStoreendpointStoreTableGroup.h"

@interface JoinGroupTableViewController : UITableViewController

@property (strong, nonatomic) GTLStoreendpointStoreTableGroup *selectedTableGroup;
@end
