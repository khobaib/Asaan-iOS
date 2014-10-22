//
//  MenuViewController.h
//  Asaan
//
//  Created by MC MINI on 10/22/14.
//  Copyright (c) 2014 Tech Fiesta. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuViewController : UIViewController<UIScrollViewDelegate>

@property NSMutableArray *menuData;
@property NSMutableArray *menuPage;

@property (strong,nonatomic) IBOutlet UIScrollView *horizontalScroller;

@end
