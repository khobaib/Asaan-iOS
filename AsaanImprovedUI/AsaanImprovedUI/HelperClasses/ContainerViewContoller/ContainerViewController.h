//
//  ContainerViewController.h
//  FutureWorld iOS
//
//  Created by Hasan Ibna Akbar on 12/17/13.
//  Copyright (c) 2013 Hasan Ibna Akbar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContainerViewController : UIViewController

@property (nonatomic, strong) NSString *segueIdentifierFirst;
@property (nonatomic, strong) NSString *segueIdentifierSecond;
@property (nonatomic, strong) NSString *segueIdentifierThird;

@property (nonatomic, strong) NSString *initialSegueIdentifier;

- (void)swapViewControllers:(int)selectedIndex;

@end
