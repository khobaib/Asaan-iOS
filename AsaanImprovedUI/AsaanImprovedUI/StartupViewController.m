//
//  ViewController.m
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 11/6/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "StartupViewController.h"

#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <MBProgressHUD.h>

@interface StartupViewController ()

@end

@implementation StartupViewController {
    
    MBProgressHUD *hud;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    //    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
    //                             forBarMetrics:UIBarMetricsDefault];
    //    self.navigationController.navigationBar.shadowImage = [UIImage new];
    //    self.navigationController.navigationBar.translucent = YES;
    
    
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.hidden=YES;
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
}

#pragma mark - Actions
- (IBAction)actionFacebookLogin:(id)sender {
    
    NSArray *permissions=@[@"public_profile", @"user_friends",@"email"];
    
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Please Wait";
    hud.hidden=NO;
    
    [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
        
        if (!user) {
            
            hud.hidden=YES;
            
#if DEBUG_LOGIN
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
#endif
            
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
        } else if (user.isNew) {
            
            
#if DEBUG_LOGIN
            NSLog(@"User signed up and logged in through Facebook!");
#endif
            
            hud.hidden=YES;
            [self facebookDataLoad];
            
        } else {
            
#if DEBUG_LOGIN
            NSLog(@"User logged in through Facebook!");
#endif
            hud.hidden=YES;
            
            NSLog(@"Test 1");
#pragma warning
//            ProfileViewController *acv=[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"profile"];
//            [self.navigationController pushViewController:acv animated:YES];
            
        }
    }];
}


- (void)facebookDataLoad {
    
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Please Wait";
    
    
    
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
        if (!error) {
            
            NSDictionary *userData = (NSDictionary *)result;
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init] ;
            
            [dateFormatter setDateFormat:@"dd/MM/YYYY"];
            PFUser *user=[PFUser currentUser];
            
            user[@"firstName"]=userData[@"first_name"];
            
            user[@"lastName"]=userData[@"last_name"];
            user[@"profilePhotoUrl"]=[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", userData[@"id"]];
            
            NSLog(@" birthday %@",userData[@"birthday"]);
            
            // user[@"birthDate"]=[dateFormatter dateFromString:userData[@"birthday"]];
            
            NSLog(@"log");
            user.email=userData[@"email"];
            
            
            [user saveInBackgroundWithBlock:^(BOOL complete,NSError *error){
                
            NSLog(@"Test 2");
#pragma warning
//                ProfileViewController *acv=[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"profile"];
//                [self.navigationController pushViewController:acv animated:YES];
                
                hud.hidden=YES;
            }];
            
        }else{
            
            hud.hidden=YES;
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
        }
    }];
}

@end
