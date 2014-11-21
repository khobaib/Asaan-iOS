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

@interface PaymentInfoViewController () <DropdownViewDelegate>

@property (weak, nonatomic) IBOutlet PTKView *ptkView;
@property (weak, nonatomic) IBOutlet UIScrollView *paymentInfoScrollView;
@property (weak, nonatomic) IBOutlet DropdownView *dropdownView;

@end

@implementation PaymentInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [super setBaseScrollView:_paymentInfoScrollView];
    
    [self.dropdownView setData:@[@"15%", @"20%", @"25%", @"30%"]];
    self.dropdownView.delegate = self;
    [self.dropdownView setDefaultSelection:1];
    self.dropdownView.listBackgroundColor = [UIColor asaanBackgroundColor];
    self.dropdownView.titleColor = [UIColor whiteColor];
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

#pragma mark - DropdownViewDelegate
- (void)dropdownViewActionForSelectedRow:(int)row sender:(id)sender
{
    NSLog(@"Selected row : %d", row);
}

@end
