//
//  AddToWaitListViewController.m
//  Savoir
//
//  Created by Nirav Saraiya on 2/11/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "AddToWaitListViewController.h"
#import "SHSPhoneTextField.h"
#import "UIView+Toast.h"
#import "InlineCalls.h"
#import "AppDelegate.h"
#import "UtilCalls.h"
#import "GTLStoreendpoint.h"

@interface AddToWaitListViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet SHSPhoneTextField *txtPhone;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtPartySize;
@property (strong, nonatomic) GTLUserendpointChatUser *chatUser;
@property (weak, nonatomic) IBOutlet UIView *headerView;

@end

@implementation AddToWaitListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.txtPartySize.text = @"1";
    [self.txtPhone.formatter setDefaultOutputPattern:@"(###) ###-####"];
    self.txtPhone.formatter.prefix = @"+1 ";
    [UtilCalls setupHeaderView:self.headerView WithTitle:@"Add to Wait-list" AndSubTitle:@"Savoir users will be automatically found by phone. Others will receive confirmation via text messages."];

    // Do any additional setup after loading the view.
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

- (IBAction)btnAddClick:(id)sender
{
    if (IsEmpty(self.txtPhone.text) || IsEmpty(self.txtName.text) || IsEmpty(self.txtPartySize.text) || self.txtPartySize.text.intValue == 0)
    {
        [self.view makeToast:@"Please enter name, phone and party size"];
        return;
    }
        
    GTLStoreendpointStoreWaitListQueue *newEntry = [[GTLStoreendpointStoreWaitListQueue alloc]init];
//    newEntry.storeId = [NSNumber numberWithLong:self.selectedStore.identifier.longLongValue];
//    newEntry.storeName = self.selectedStore.name;
//    int time = (self.storeWaitListSummary.partiesOfSize12.intValue + self.storeWaitListSummary.partiesOfSize34.intValue + self.storeWaitListSummary.partiesOfSize5OrMore.intValue)*2;
//    newEntry.estTimeMin = [NSNumber numberWithInt:(time + 15)];
//    newEntry.estTimeMax = [NSNumber numberWithInt:(time + 30)];
    newEntry.partySize = [NSNumber numberWithInt:self.txtPartySize.text.intValue];
    newEntry.userId = self.chatUser.userId;
    newEntry.userName = self.txtName.text;
    newEntry.userPhone = self.txtPhone.text;
    [self.receiver setQueueEntry:newEntry];
    [UtilCalls popFrom:self index:1 Animated:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    
    UITextField *next = theTextField.nextTextField;
    if (next) {
        [next becomeFirstResponder];
    } else {
        [self.view endEditing:YES];
    }
    
    if (theTextField == self.txtPartySize) {
        [self btnAddClick:self];
    }
    
    return YES;
}

- (IBAction)phoneEditingDidEnd:(id)sender
{
    if (self.txtPhone.text.length > 2 && self.txtPhone.text.length < 15)
    {
        [self.view makeToast:@"Please enter a valid phone number"];
        return;
    }
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
                 weakSelf.txtName.text = nil;
             }
             else
             {
                 weakSelf.chatUser = chatUser;
                 weakSelf.txtName.text = chatUser.name;
             }
         }
         else
         {
             NSString *msg = @"Get User By Phone Failed. Please try again. If this failure persists please contact Savoir Customer Support.";
             [UtilCalls handleGAEServerError:error Message:msg Title:@"Savoir Error" Silent:false];
         }
     }];
}
- (IBAction)partySizeValueChanged:(id)sender
{
    if (self.txtPartySize.text.intValue < 1)
        self.txtPartySize.text = @"1";
}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
//{
//    if ([textField isEqual:self.zip])
//    {
//        NSString *resultString = [self.zip.text stringByReplacingCharactersInRange:range withString:replacementString];
//        resultString = [PTKTextField textByRemovingUselessSpacesFromString:resultString];
//        PTKUSAddressZip *addressZIP = [PTKUSAddressZip addressZipWithString:resultString];
//        
//        // Restrict length
//        if (![addressZIP isPartiallyValid]) return NO;
//        
//        // Strip non-digits
//        //        self.zip.text = [addressZIP string];
//        
//        if (![addressZIP isValid])
//        {
//            if (![addressZIP isPartiallyValid]) return NO;
//        }
//        else
//            return YES;
//    }
//    
//    return YES;
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
