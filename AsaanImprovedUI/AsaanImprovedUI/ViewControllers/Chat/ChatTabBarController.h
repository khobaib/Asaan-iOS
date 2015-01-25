//
//  ChatTabBarController.h
//  AsaanImprovedUI
//
//  Created by Hasan Ibna Akbar on 1/25/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GroupView, ChatView;
@interface ChatTabBarController : UITabBarController

@property (strong, nonatomic) GroupView *groupView;
@property (strong, nonatomic) ChatView *chatView;

@property (weak, nonatomic) UINavigationController *parentNavigationController;

@end
