//
//  StoreListViewController.m
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 11/14/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "StoreListViewController.h"
#import "MBProgressHUD.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface StoreListViewController()
{
    MBProgressHUD *hud;
}
@end

@implementation StoreListViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.hidden=NO;
    PFUser *currentUser = [PFUser currentUser];
    hud.hidden=YES;
    if (!currentUser) {
        [self performSegueWithIdentifier:@"segueLogin" sender:self];
    }
}

@end
