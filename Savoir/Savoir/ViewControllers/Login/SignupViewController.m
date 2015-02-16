//
//  SignupViewController.m
//  Savoir
//
//  Created by Nirav Saraiya on 11/7/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "SignupViewController.h"
#import "UIColor+SavoirGoldColor.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "InlineCalls.h"
#import "MBProgressHUD.h"
#import "Extension.h"

@interface SignupViewController () <UITextFieldDelegate>

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
    if ([self validateForm] == false) return;
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

- (Boolean) validateForm
{
    Boolean isFormValid = false;
    if (IsEmpty(_txtEmail.text) == false)
        isFormValid = true;

    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
//    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stricterFilterString];
    isFormValid = [emailTest evaluateWithObject:_txtEmail.text];
    
//    isFormValid = [_txtEmail.text containsString:@".."];
//    isFormValid = [_txtEmail.text customContainsString:@".."];
    
    if (isFormValid == false)
    {
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error" message:@"Please Enter a valid Email Address." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        [alert show];
        return false;
    }
    
    if (_txtPassword.text.length >= 6)
    {
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error" message:@"Please Enter a valid. Passwords must be at least 6 characters." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        [alert show];
        return false;
    }

    return true;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
   
    UIColor *color = [UIColor lightTextColor];
    _txtEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"name@example.com" attributes:@{NSForegroundColorAttributeName: color}];
    _txtPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Min 8 characters" attributes:@{NSForegroundColorAttributeName: color}];
    PFUser *user = [PFUser currentUser];
    if (user != nil && IsEmpty(user[@"firstName"]) == false)
        _txtEmail.text = user.email;
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

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.txtPassword) {
        [self signup:self];
    }
    
    return [super textFieldShouldReturn:textField];
}

@end
