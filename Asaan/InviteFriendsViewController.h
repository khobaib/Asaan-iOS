//
//  InviteFriendsViewController.h
//  Asaan
//
//  Created by MC MINI on 9/22/14.
//  Copyright (c) 2014 Tech Fiesta. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InviteFriendsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *arr;

}

@property IBOutlet UITableView *tableView;
@end
