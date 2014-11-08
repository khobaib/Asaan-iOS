//
//  CheckoutOrderViewController.h
//  Asaan
//
//  Created by MC MINI on 10/29/14.
//  Copyright (c) 2014 Tech Fiesta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatabaseHelper.h"

@interface CheckoutOrderViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
       NSArray *tableData;
    float totalSum;
}


@property IBOutlet UITableView *tableView;
@property IBOutlet UILabel *total;
@end
