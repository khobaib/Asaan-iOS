//
//  MenuViewController.h
//  Asaan
//
//  Created by MC MINI on 10/22/14.
//  Copyright (c) 2014 Tech Fiesta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLStoreendpoint.h"


@interface MenuViewController : UIViewController<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>{
    NSNumber *menuPosID;
    
    //Array for top scroll , menu
     NSMutableArray *menuLevel0Array;
     NSMutableArray *menuPage;
    
    //Array for section header
     NSMutableArray *headerArray;
    //Array for table data
     NSMutableArray *tableDataArray;
    
    
    GTLStoreendpointMenusAndMenuItems *menuHierarchyCollectionObject;
}



@property (strong,nonatomic) IBOutlet UIScrollView *horizontalScroller;
@property NSNumber *storeID;

@property IBOutlet UITableView *tableView;

@end
