//
//  FinalPaymentViewController.m
//  Savoir
//
//  Created by Nirav Saraiya on 4/5/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "FinalPaymentViewController.h"
#import "AppDelegate.h"
#import "UtilCalls.h"
#import "MBProgressHUD.h"
#import "InlineCalls.h"
#import "Extension.h"
#import "InStoreOrderDetails.h"
#import "OrderItemSummaryFromPOS.h"
#import "RXMLElement.h"
#import "OrderedDictionary.h"
#import "StripePay.h"
#import "GTLStoreendpointSplitOrderArguments.h"
#import "SelectPaymentTableViewController.h"
#import "InStoreOrderReceiver.h"

@interface FinalPaymentViewController ()<InStoreOrderReceiver>
@property (weak, nonatomic) IBOutlet UISegmentedControl *tipSegmentController;
@property (weak, nonatomic) IBOutlet UISlider *tipSlider;
@property (weak, nonatomic) IBOutlet UILabel *txtSubTotal;
@property (weak, nonatomic) IBOutlet UILabel *txtTip;
@property (weak, nonatomic) IBOutlet UILabel *txtTax;
@property (weak, nonatomic) IBOutlet UILabel *txtFinalAmount;
@property (weak, nonatomic) IBOutlet UILabel *txtTipLabel;

@property (nonatomic, strong) NSMutableArray *finalItems;
@property (strong, nonatomic) NSString *discountName;
@property (nonatomic) float discountAmt;

@property (strong, nonatomic) StripePay *stripePay;

@end

@implementation FinalPaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.stripePay = [[StripePay alloc]init];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if (self.navigationController.viewControllers[0] != self)
        self.navigationItem.leftBarButtonItem = nil;
    else
        [appDelegate.notificationUtils getSlidingMenuBarButtonSetupWith:self];
    
    int defaultTip = appDelegate.globalObjectHolder.currentUser.defaultTip.intValue;
    if (defaultTip <= 18)
    {
        self.tipSegmentController.selectedSegmentIndex = 0;
        self.tipSlider.value = 18;
    }
    else if (defaultTip == 20)
    {
        self.tipSegmentController.selectedSegmentIndex = 1;
        self.tipSlider.value = 20;
    }
    else if (defaultTip == 25)
    {
        self.tipSegmentController.selectedSegmentIndex = 2;
        self.tipSlider.value = 25;
    }
    else
    {
        self.tipSegmentController.selectedSegmentIndex = 3;
        self.tipSlider.value = defaultTip;
    }
    NSLog(@"FinalPaymentViewController viewDidLoad");
}

- (void)viewWillAppear:(BOOL)animated
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [appDelegate.globalObjectHolder.inStoreOrderDetails getGroupMembers:self];
    [appDelegate.globalObjectHolder.inStoreOrderDetails getStoreOrderDetails:self];
    NSLog(@"FinalPaymentViewController viewWillAppear finalItems count = %lu", (unsigned long)self.finalItems.count);
}

- (void)orderChanged
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    self.finalItems = [appDelegate.globalObjectHolder.inStoreOrderDetails parseOrderDetails];
    [self updatePaymentValues];
    NSLog(@"FinalPaymentViewController orderChanged finalItems count = %lu", (unsigned long)self.finalItems.count);
}

- (void) tableGroupMemberChanged
{
    [self updatePaymentValues];
    NSLog(@"FinalPaymentViewController tableGroupMemberChanged finalItems count = %lu", (unsigned long)self.finalItems.count);
}

- (void)openGroupsChanged
{
    // Don't care
}

- (NSUInteger) payingForCount
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    int payingForCount = 0;
    for (GTLStoreendpointStoreTableGroupMember *member in appDelegate.globalObjectHolder.inStoreOrderDetails.tableGroupMembers.items)
    {
        if (member.payingUserId.longLongValue == appDelegate.globalObjectHolder.currentUser.identifier.longLongValue)
            payingForCount++;
    }
    return payingForCount;
}

- (NSUInteger) groupCount
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    return appDelegate.globalObjectHolder.inStoreOrderDetails.tableGroupMembers.items.count;
}

- (void) updatePaymentValues
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if (appDelegate.globalObjectHolder.inStoreOrderDetails.order == nil || [self groupCount] == 0)
        return;
    self.txtFinalAmount.text = [UtilCalls rawAmountToString:[NSNumber numberWithDouble:[self finalTotal]]];
    self.txtSubTotal.text = [UtilCalls rawAmountToString:[NSNumber numberWithDouble:([self subTotalNoDiscountMyShare] - [self discount])]];
    self.txtTip.text = [UtilCalls rawAmountToString:[NSNumber numberWithDouble:[self gratuity]]];
    self.txtTax.text = [UtilCalls rawAmountToString:[NSNumber numberWithDouble:[self taxAmount]]];
    self.txtTipLabel.text = [NSString stringWithFormat:@"Tip (%d%%):", (int)(self.tipSlider.value)];
    
    GTLStoreendpointStoreTableGroupMember *memberMe = appDelegate.globalObjectHolder.inStoreOrderDetails.memberMe;
    memberMe.finalTotal = [NSNumber numberWithDouble:[self finalTotal]];
    memberMe.subtotal = [NSNumber numberWithDouble:([self subTotalNoDiscountMyShare] - [self discount])];
    memberMe.tip = [NSNumber numberWithDouble:[self gratuity]];
    memberMe.tax = [NSNumber numberWithDouble:([self taxAmount])];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tipSegmentControllerValueChanged:(id)sender
{
    if (self.tipSegmentController.selectedSegmentIndex == 0)
        self.tipSlider.value = 18;
    else if (self.tipSegmentController.selectedSegmentIndex == 1)
        self.tipSlider.value = 20;
    else if (self.tipSegmentController.selectedSegmentIndex == 2)
        self.tipSlider.value = 25;
    
    [self updatePaymentValues];
}

- (IBAction)tipSliderValueChanged:(id)sender
{
    self.tipSegmentController.selectedSegmentIndex = 3;
    
    [self updatePaymentValues];
}

- (double)subTotalNoDiscountFull
{
    NSUInteger subTotalNoDiscount = 0;
    for (OrderItemSummaryFromPOS *item in self.finalItems)
        subTotalNoDiscount += item.price;
    return subTotalNoDiscount;
}

- (double)subTotalNoDiscountMyShare
{
    if ([self groupCount] == 0)
        return 0;
    else
        return [self subTotalNoDiscountFull]*[self payingForCount]/[self groupCount];
}

- (double)discount
{
    if ([self groupCount] == 0)
        return 0;
    else
        return self.discountAmt*[self payingForCount]/[self groupCount];
}

- (double)gratuity
{
    return [self subTotalNoDiscountMyShare] * self.tipSlider.value/100;
}

- (double)taxAmount
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    double tax = appDelegate.globalObjectHolder.inStoreOrderDetails.selectedStore.taxPercent.longValue/10000.0;
    return ([self subTotalNoDiscountMyShare] - [self discount] + [self gratuity])*tax;
}

- (double)finalTotal
{
    return [self subTotalNoDiscountMyShare] - [self discount] + [self gratuity] + [self taxAmount];
}

- (Boolean) placeOrderWithToken:(STPToken *)token
{
    return false;
}

- (IBAction)payNowClicked:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    if ([self finalTotal] < 1)
        return;
    
    if (self.stripePay.applePayEnabled)
    {
        if (self.stripePay.token == nil)
        {
            NSString *amountStr = [UtilCalls doubleAmountToString:[NSNumber numberWithDouble:[self finalTotal]]];
            NSDecimalNumber *finalAmount = [NSDecimalNumber decimalNumberWithString:amountStr];
            [self.stripePay beginApplePay:self Title:appDelegate.globalObjectHolder.inStoreOrderDetails.selectedStore.name Label:@"Order" AndAmount:finalAmount];
            return;
        }
    }
    else
    {
        if (appDelegate.globalObjectHolder.defaultUserCard == nil)
        {
            UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            SelectPaymentTableViewController *destination = [mainStoryBoard instantiateViewControllerWithIdentifier:@"SelectPaymentTableViewController"];
            
            UIStoryboardSegue *segue = [UIStoryboardSegue segueWithIdentifier:@"segueInstorePayToSelectPaymentTableViewController" source:self destination:destination performHandler:^(void) {
                //view transition/animation
                [self.navigationController pushViewController:destination animated:YES];
            }];
            
            [self shouldPerformSegueWithIdentifier:segue.identifier sender:self];//optional
            [self prepareForSegue:segue sender:self];
            
            [segue perform];
            return;
        }
    }
    
    GTLStoreendpointSplitOrderArguments *orderArguments = [[GTLStoreendpointSplitOrderArguments alloc]init];
    
    if (self.stripePay.applePayEnabled && self.stripePay.token != nil)
        orderArguments.token = self.stripePay.token.tokenId;
    else
    {
        orderArguments.cardid = appDelegate.globalObjectHolder.defaultUserCard.cardId;
        orderArguments.customerId = appDelegate.globalObjectHolder.defaultUserCard.providerCustomerId;
    }
    orderArguments.stgm = appDelegate.globalObjectHolder.inStoreOrderDetails.memberMe;

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Please Wait";
    hud.hidden = NO;
    
    if (self)
    {
        __weak __typeof(self) weakSelf = self;
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
        GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForPayForMemberWithObject:orderArguments];
        
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
        dic[USER_AUTH_TOKEN_HEADER_NAME]=[UtilCalls getAuthTokenForCurrentUser];
        
        [query setAdditionalHTTPHeaders:dic];
        
        [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object,NSError *error)
         {
             if(!error)
             {
                 NSString *title = [NSString stringWithFormat:@"Your Payment - %@", appDelegate.globalObjectHolder.inStoreOrderDetails.selectedStore.name];
                 NSString *msg = [NSString stringWithFormat:@"Thank you - your payment has been received and will be processed soon."];
                 UIAlertView *alert=[[UIAlertView alloc]initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                 [alert show];
                 NotificationUtils *notificationUtils = [[NotificationUtils alloc]init];
                 [notificationUtils scheduleNotificationWithOrder:appDelegate.globalObjectHolder.inStoreOrderDetails.order];
                 [appDelegate.globalObjectHolder removeInStoreOrderInProgress];
//                 if (self.revealViewController != nil)
//                     [weakSelf performSegueWithIdentifier:@"SWOrderSummaryToStoreList" sender:weakSelf];
//                 else
                     [weakSelf performSegueWithIdentifier:@"segueUnwindBillToStoreList" sender:weakSelf];
             }else{
                 NSLog(@"queryForPayForMemberWithObject Error:%@",[error userInfo][@"error"]);
             }
             hud.hidden = YES;
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
