//
//  InfoViewController.h
//  Savoir
//
//  Created by Hasan Ibna Akbar on 12/16/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLStoreendpoint.h"

@interface InfoViewController : UITableViewController

@property (nonatomic, strong) GTLStoreendpointStore *selectedStore;

@end
