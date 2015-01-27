//
//  ChatTabBarController.m
//  AsaanImprovedUI
//
//  Created by Hasan Ibna Akbar on 1/25/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "ChatTabBarController.h"

//#import "SWRevealViewController.h"
#import "NavigationController.h"
#import "GroupView.h"
#import "ChatView.h"
#import "UtilCalls.h"

@interface ChatTabBarController () <UITabBarControllerDelegate> {

    BOOL userHasCompletedAction;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *revealButtonItem;

@end

@implementation ChatTabBarController {
    
    NavigationController *navController1;
    NavigationController *navController2;
//    [[self.tabBarController.tabBar.items objectAtIndex:0] setTitle:@"Groups"];
//    [[self.tabBarController.tabBar.items objectAtIndex:1] setTitle:@"Messages"];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Groups";
    
    self.groupView = [[GroupView alloc] init];
    self.chatView = [[ChatView alloc] init];
    
    navController1 = [[NavigationController alloc] initWithRootViewController:self.groupView];
    navController2 = [[NavigationController alloc] initWithRootViewController:self.chatView];
    
    self.viewControllers = [NSArray arrayWithObjects:navController1, navController2, nil];
    self.tabBar.translucent = NO;
    self.selectedIndex = 0;
    self.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.groupView.tabBarItem.title = @"Groups";
    self.chatView.tabBarItem.title = @"Message";
    
    navController1.parentNavigationController = self.parentNavigationController;
    navController2.parentNavigationController = self.parentNavigationController;
    
    if (self.parentNavigationController) {
        [self.parentNavigationController setNavigationBarHidden:NO animated:NO];
        [navController1 setNavigationBarHidden:YES animated:NO];
        [navController2 setNavigationBarHidden:YES animated:NO];
    }
    else {
        
        UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon"] style:UIBarButtonItemStylePlain target:nil action:nil];
        self.groupView.navigationItem.leftBarButtonItem = revealButtonItem;
        
        [UtilCalls slidingMenuSetupWith:self.groupView withItem:revealButtonItem];
        
        revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon"] style:UIBarButtonItemStylePlain target:nil action:nil];
        self.chatView.navigationItem.leftBarButtonItem = revealButtonItem;
        
        [UtilCalls slidingMenuSetupWith:self.chatView withItem:revealButtonItem];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {

    static NSString * title = @"";
    if (self.selectedIndex == 1) { // reverse
        title = self.title;
        self.title = @"Groups";
    }
    else if (self.selectedIndex == 0) {
        self.title = title;
    }
    
}

-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    
    if (self.selectedIndex == 0 && !self.chatView.roomId) {
        return NO;
    }
    return YES;
}

@end