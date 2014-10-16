//
//  LoginViewController.m
//  Asaan
//
//  Created by MC MINI on 9/24/14.
//  Copyright (c) 2014 Tech Fiesta. All rights reserved.
//

#import "LoginViewController.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <Parse/Parse.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIColor *color = [UIColor colorWithRed:0.8f green:0.8f blue:0.8 alpha:1];
    self.emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email:" attributes:@{NSForegroundColorAttributeName: color}];
    
    self.passwordFild.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password:" attributes:@{NSForegroundColorAttributeName: color}];

    
    
    
    // Do any additional setup after loading the view.
}

-(IBAction)login:(id)sender{
    NSString *email=self.emailField.text;
    NSString *pass=self.passwordFild.text;
    
    if([email isEqualToString:@""]||[pass isEqualToString:@""]){
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error" message:@"Please Enter Email And Password." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        [alert show];
        return;
    }
    
    [PFUser logInWithUsernameInBackground:email password:pass block:^(PFUser *user,NSError *error){
        if(user){
            NSLog(@"%@",[user description]);
            [self performSegueWithIdentifier:@"profilePage" sender:self];

        }else{
            NSLog(@"%@",[error userInfo]);
        }
    }];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark -keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    
    return [textField resignFirstResponder];
}



- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
        self.navigationController.navigationBarHidden=YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - keyboard movements
- (void)keyboardWillShow:(NSNotification *)notification
{
    int height=[UIScreen mainScreen].bounds.size.height;

    
    if(height==480){
        [UIView animateWithDuration:0.3 animations:^{
            CGRect f = self.view.frame;
            f.origin.y = -60; //set the -35.0f to your required value
            self.view.frame = f;
        }];
        
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            CGRect f = self.view.frame;
            f.origin.y = -40; //set the -35.0f to your required value
            self.view.frame = f;
        }];
        

    }
    
    
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = 0.0f;
        self.view.frame = f;
    }];
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
