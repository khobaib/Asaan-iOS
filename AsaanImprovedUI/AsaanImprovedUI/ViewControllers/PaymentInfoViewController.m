//
//  StripeViewController.m
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 11/10/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "PaymentInfoViewController.h"
#import "PTKView.h"
#import "UIColor+AsaanGoldColor.h"

@interface PaymentInfoViewController ()
@property (weak, nonatomic) IBOutlet PTKView *ptkView;
@end

@implementation PaymentInfoViewController

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor : [UIColor goldColor]};
    
<<<<<<< HEAD:AsaanImprovedUI/AsaanImprovedUI/ViewControllers/PaymentInfoViewController.m
    // Prevent keyboard from showing by default
    [self.view endEditing:YES];
//    _ptkView.delegate = self;
=======
    //    _ptkView.delegate = self;
    
    NSLog(@"User %@", self.userInfo.email);
>>>>>>> FETCH_HEAD:AsaanImprovedUI/AsaanImprovedUI/StripeViewController.m
}

@end
