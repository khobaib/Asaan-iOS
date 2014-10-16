//
//  ResturantDetailViewController.h
//  Asaan
//
//  Created by MC MINI on 9/23/14.
//  Copyright (c) 2014 Tech Fiesta. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResturantDetailViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property IBOutlet UIView *containerView;
@property IBOutlet UITableView *tableView;
@property IBOutlet UISegmentedControl *segment;





@end
