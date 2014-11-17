//
//  LoginViewController.m
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 11/7/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "LoginViewController.h"
#import "UIColor+AsaanGoldColor.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>
#import "InlineCalls.h"

@interface LoginViewController ()
    @property (weak, nonatomic) IBOutlet UITextField *txtEmail;
    @property (weak, nonatomic) IBOutlet UITextField *txtPassword;
    @property (weak, nonatomic) IBOutlet UIScrollView *loginScrollView;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [super setBaseScrollView:_loginScrollView];
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

- (IBAction)login:(id)sender {
    NSString *email = _txtEmail.text;
    NSString *password = _txtPassword.text;
    
    if (IsEmpty(email) || IsEmpty(password)) {
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error" message:@"Please Enter Email And Password." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        [alert show];
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Please Wait";
    hud.hidden = NO;
    
    [PFUser logInWithUsernameInBackground:email password:password block:^(PFUser *user,NSError *error){
        hud.hidden = YES;
        if(user){
            NSLog(@"%@",[user description]);
//            [self performSegueWithIdentifier:@"profilePage" sender:self];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else{
            NSLog(@"%@",[error userInfo]);
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
    }];
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
