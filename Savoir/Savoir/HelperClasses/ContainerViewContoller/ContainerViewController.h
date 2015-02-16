//
//  ContainerViewController.h
//  FutureWorld iOS
//
//  Created by Hasan Ibna Akbar on 12/17/13.
//  Copyright (c) 2013 Hasan Ibna Akbar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ContainerViewController;
@protocol ContainerViewControllerDelegate <NSObject>

- (void)containerViewController:(ContainerViewController *)containerViewController willShowViewController:(UIViewController*)viewController;

@end

@interface ContainerViewController : UIViewController

@property (nonatomic, strong) NSArray *segues;
@property (nonatomic, assign) NSUInteger initialIndex;

@property (nonatomic, weak) id<ContainerViewControllerDelegate> delegate;

- (void)swapViewControllers:(int)selectedIndex;

@end
