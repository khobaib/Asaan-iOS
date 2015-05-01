//
//  NoNetworkViewController.m
//  Savoir
//
//  Created by Nirav Saraiya on 4/29/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "NoNetworkViewController.h"
#import "AppDelegate.h"

@interface NoNetworkViewController ()

@end

@implementation NoNetworkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    appDelegate.topViewController = self;
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
