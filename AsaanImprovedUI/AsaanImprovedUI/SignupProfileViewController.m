//
//  SignupProfileViewController.m
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 11/10/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "SignupProfileViewController.h"
#import "UIColor+AsaanGoldColor.h"
#import "StripeViewController.h"

@interface SignupProfileViewController ()

@property (weak, nonatomic) IBOutlet UIButton *profileImageView;
@property (weak, nonatomic) IBOutlet UITextField *txtLastName;
@property (weak, nonatomic) IBOutlet UITextField *txtFirstName;
@property (weak, nonatomic) IBOutlet UIScrollView *signupProfileScrollView;

@end

@implementation SignupProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [super setBaseScrollView:_signupProfileScrollView];
    
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    self.profileImageView.clipsToBounds = YES;
    self.profileImageView.layer.borderWidth = 3.0f;
    self.profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    // NOTE: Rounded rect
    // self.profileImageView.layer.cornerRadius = 10.0f;
    
    UIColor *color = [UIColor lightTextColor];
    _txtLastName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Smith" attributes:@{NSForegroundColorAttributeName: color}];
    _txtFirstName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"John" attributes:@{NSForegroundColorAttributeName: color}];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor : [UIColor goldColor]};
}

- (void)viewDidAppear:(BOOL)animated {
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"SignupProfileToStripeSegue"]) {
        
        self.userInfo.firstName = _txtFirstName.text;
        self.userInfo.lastName = _txtLastName.text;
        
        ((StripeViewController *)segue.destinationViewController).userInfo = self.userInfo;
    }
}

@end
