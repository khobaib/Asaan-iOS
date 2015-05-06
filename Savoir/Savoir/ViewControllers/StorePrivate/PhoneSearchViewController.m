//
//  PhoneSearchViewController.m
//  Savoir
//
//  Created by Nirav Saraiya on 2/10/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "PhoneSearchViewController.h"
#import "SHSPhoneTextField.h"
#import "InlineCalls.h"
#import "AppDelegate.h"
#import "UtilCalls.h"

@interface PhoneSearchViewController ()
@property (weak, nonatomic) IBOutlet UILabel *txtName;
@property (weak, nonatomic) IBOutlet SHSPhoneTextField *txtPhone;
@property (weak, nonatomic) IBOutlet UIButton *btnAddEmployee;
@property (strong, nonatomic) GTLUserendpointChatUser *chatUser;
@property (weak, nonatomic) IBOutlet UIView *headerView;

@end

@implementation PhoneSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.txtPhone.formatter setDefaultOutputPattern:@"(###) ###-####"];
    self.txtPhone.formatter.prefix = @"+1 ";
    
    [UtilCalls setupHeaderView:self.headerView WithTitle:@"Select Employee by Phone" AndSubTitle:@"Make Sure Employee Has Joined Savoir First."];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    appDelegate.topViewController = self;

    if (IsEmpty(self.txtName.text))
        self.btnAddEmployee.enabled = false;
    else
        self.btnAddEmployee.enabled = true;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)btnAdd:(id)sender
{
    if (IsEmpty(_txtPhone.text) || _txtPhone.text.length < 10)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Please enter full phone number" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        [self.receiver setChatUser:self.chatUser];
        [UtilCalls popFrom:self index:1 Animated:YES];
    }
}
- (IBAction)btnSearch:(id)sender
{
    if (IsEmpty(_txtPhone.text) || _txtPhone.text.length < 10)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Please enter a valid phone number" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        __weak __typeof(self) weakSelf = self;
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        GTLServiceUserendpoint *gtlUserService= [appDelegate gtlUserService];
        GTLQueryUserendpoint *query = [GTLQueryUserendpoint queryForGetUserByPhoneWithPhone:_txtPhone.text];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        dic[USER_AUTH_TOKEN_HEADER_NAME] = [UtilCalls getAuthTokenForCurrentUser];
        [query setAdditionalHTTPHeaders:dic];
        [gtlUserService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLUserendpointChatUser *chatUser, NSError *error)
         {
             if (!error)
             {
                 if (IsEmpty(chatUser.name))
                 {
                     weakSelf.chatUser = nil;
                     weakSelf.txtName.text = @"User not found";
                     weakSelf.btnAddEmployee.enabled = false;
                 }
                 else
                 {
                     weakSelf.chatUser = chatUser;
                     weakSelf.txtName.text = chatUser.name;
                     weakSelf.btnAddEmployee.enabled = true;
                 }
             }
             else
             {
                 NSString *msg = @"Failed to get search for a user by phone. Please retry in a few minutes. If this error persists please contact Savoir Customer Assistance team.";
                 [UtilCalls handleGAEServerError:error Message:msg Title:@"Savoir Error" Silent:false];
             }
         }];
    }
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
