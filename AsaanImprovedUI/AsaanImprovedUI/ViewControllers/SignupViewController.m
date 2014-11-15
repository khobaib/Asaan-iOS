//
//  SignupViewController.m
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 11/7/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "SignupViewController.h"
#import "UIColor+AsaanGoldColor.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "InlineCalls.h"
#import "MBProgressHUD.h"

@interface SignupViewController ()
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UIScrollView *signupScrollView;

@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [super setBaseScrollView:_signupScrollView];
//    self.navigationController.navigationBar.translucent = YES;
}

- (IBAction)signup:(id)sender {
    
    if (IsEmpty(_txtEmail.text) || IsEmpty(_txtPassword.text)) {
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error" message:@"Please Enter Email And Password." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        [alert show];
        return;
    }
    PFUser *user=[PFUser user];
    user.email = _txtEmail.text;
    user.username = _txtEmail.text;
    user.password = _txtPassword.text;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Please Wait";
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        hud.hidden=YES;
        if (!error) {
            [self performSegueWithIdentifier:@"segueSignupToSignupProfile" sender:self];
       } else {
            NSString *errorString = [error localizedDescription];
            // Show the errorString somewhere and let the user try again.
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor : [UIColor goldColor]};
    
    UIColor *color = [UIColor lightTextColor];
    _txtEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"name@example.com" attributes:@{NSForegroundColorAttributeName: color}];
    _txtPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Min 8 characters" attributes:@{NSForegroundColorAttributeName: color}];
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

@end
