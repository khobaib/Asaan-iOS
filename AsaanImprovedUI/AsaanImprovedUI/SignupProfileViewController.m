//
//  SignupProfileViewController.m
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 11/10/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "SignupProfileViewController.h"
#import "UIColor+AsaanGoldColor.h"

@interface SignupProfileViewController ()
@property (weak, nonatomic) IBOutlet UIButton *profileImageView;

@end

@implementation SignupProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    self.profileImageView.clipsToBounds = YES;
    self.profileImageView.layer.borderWidth = 3.0f;
    self.profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    // NOTE: Rounded rect
    // self.profileImageView.layer.cornerRadius = 10.0f;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
 
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor : [UIColor goldColor]};
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [button setBackgroundImage:[UIImage imageNamed:@"nextSinguppage.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(nextPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn=[[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.rightBarButtonItem=btn;
}

-(void)nextPressed:(id)sender{
   
    [self performSegueWithIdentifier:@"addCard" sender:self];
}


- (void)viewDidAppear:(BOOL)animated {
}

@end
