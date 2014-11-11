//
//  SignupViewController.m
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 11/7/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "SignupViewController.h"
#import "UIColor+AsaanGoldColor.h"

@interface SignupViewController ()

@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.navigationController.navigationBar.translucent = YES;
    
    
    UIColor *color = [UIColor lightTextColor];
    _textEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"name@example.com" attributes:@{NSForegroundColorAttributeName: color}];
    _textPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Min 8 characters" attributes:@{NSForegroundColorAttributeName: color}];
    _textPhone.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"(***)***-****" attributes:@{NSForegroundColorAttributeName: color}];
    
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
   

    self.navigationController.navigationBarHidden=NO;
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor : [UIColor goldColor]};
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [button setBackgroundImage:[UIImage imageNamed:@"nextSinguppage.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(nextPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn=[[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.rightBarButtonItem=btn;
   
}

-(void)viewWillDisappear:(BOOL)animated{
    self.navigationItem.rightBarButtonItem=nil;
}

-(void)nextPressed:(id)sender{
    if([_textEmail.text isEqualToString:@""]||[_textPassword.text isEqualToString:@""]||[_textPhone.text isEqualToString:@""]){
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Please fillup all the fields" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    [self performSegueWithIdentifier:@"profileInfo" sender:self];
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
