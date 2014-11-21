//
//  ViewController.m
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 11/6/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "StartupViewController.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "MBProgressHUD.h"
#import "InlineCalls.h"

@interface StartupViewController ()
{
    MBProgressHUD *hud;
}
@end

@implementation StartupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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

- (IBAction)connectWithFacebook:(id)sender {

//#warning Comment out for testing
    NSArray *permissions=@[@"public_profile", @"user_friends",@"email"];
    
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Please Wait";
    hud.hidden=NO;
    [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
        hud.hidden=YES;
        if (!user) {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
//        } else if (user.isNew) {
//            NSLog(@"User signed up and logged in through Facebook!");
        } else {
            [self _loadData];
        }
    }];
    
//#warning Code for testing
//    [self performSegueWithIdentifier:@"segueStartupToAddPayment" sender:self];

}
- (void)_loadData {
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
            user.username = user.email = userData[@"email"];
            
            [user saveInBackgroundWithBlock:^(BOOL complete,NSError *error){
                hud.hidden=YES;
                if (!error){
                    NSString *strPhone = user[@"phone"];
                    if (IsEmpty(strPhone)){
                        [self performSegueWithIdentifier:@"segueStartupToPhoneFB" sender:self];
                    }
                    else
                        [self dismissViewControllerAnimated:YES completion:Nil];
                } else {
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK"     otherButtonTitles:nil];
                    [alert show];
                }
            }];
        }else{
            hud.hidden=YES;
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];
}

@end
