//
//  MenuWebViewController.m
//  Savoir
//
//  Created by Nirav Saraiya on 4/26/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "MenuWebViewController.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"

@interface MenuWebViewController()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation MenuWebViewController

-(void)viewDidLoad
{
    self.webView.delegate = self;
    NSMutableURLRequest * request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.menuURL]];
    [self.webView loadRequest:request];
    self.navigationItem.title = [NSString stringWithFormat:@"%@ Menu", self.storeName];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    appDelegate.topViewController = self;
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Please Wait";
    hud.hidden = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSString *errMsg = [NSString stringWithFormat:@"Failed to connect to %@'s WebMenu. Error: %@", self.storeName, error.localizedDescription];
    [[[UIAlertView alloc]initWithTitle:@"Error" message:errMsg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

@end
