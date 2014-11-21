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
#import "UIColor+AsaanBackgroundColor.h"
#import "DropdownView.h"

@interface PaymentInfoViewController ()
@property (weak, nonatomic) IBOutlet UIView *ptkView;
@property (weak, nonatomic) IBOutlet UIScrollView *paymentInfoScrollView;
@property (weak, nonatomic) IBOutlet DropdownView *dropdownView;

@end

@implementation PaymentInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [super setBaseScrollView:_paymentInfoScrollView];
    
    [self.dropdownView setData:@[@"15%", @"20%", @"25%", @"30%"]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor : [UIColor goldColor]};
    
    // Prevent keyboard from showing by default
    [self.view endEditing:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    
    CGRect frame = {.origin = {0, 0}, .size = self.ptkView.frame.size};
    [self.ptkView addSubview:[[PTKView alloc] initWithFrame:frame]];
}

@end
