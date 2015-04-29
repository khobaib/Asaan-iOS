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
#import "XMLPOSOrder.h"

@interface FinalPaymentViewController ()<InStoreOrderReceiver>
@property (weak, nonatomic) IBOutlet UISegmentedControl *tipSegmentController;
@property (weak, nonatomic) IBOutlet UISlider *tipSlider;
@property (weak, nonatomic) IBOutlet UILabel *txtSubTotal;
@property (weak, nonatomic) IBOutlet UILabel *txtTip;
@property (weak, nonatomic) IBOutlet UILabel *txtTax;
@property (weak, nonatomic) IBOutlet UILabel *txtFinalAmount;
@property (weak, nonatomic) IBOutlet UILabel *txtTipLabel;
@property (weak, nonatomic) IBOutlet UIButton *btnPayNow;

@property (nonatomic, strong) NSMutableArray *finalItems;

@property (strong, nonatomic) StripePay *stripePay;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation FinalPaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.stripePay = [[StripePay alloc]init];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
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
    [self refreshOrderDetails];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startTimer];
}

- (void)startTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:35.0 target:self selector:@selector(refreshOrderDetails) userInfo:nil repeats:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [super viewWillDisappear:animated];
    [self.timer invalidate];
}

- (void)refreshOrderDetails
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [appDelegate.globalObjectHolder.inStoreOrderDetails getStoreOrderDetails:self];
}

- (void)orderChanged
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if (appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.memberMe == nil
        || appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order.orderStatus.intValue == 4 // Fully Paid
        || appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order.orderStatus.intValue == 5) // Paid and Closed
    {
        [self.timer invalidate];
        [UtilCalls handleClosedOrderFor:self SegueTo:@"segueUnwindMemberPayToStoreList"];
    }
    
    self.finalItems = [XMLPOSOrder parseOrderDetails:appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order.orderDetails];
    [self updatePaymentValues];
    
    if ([self subTotalNoDiscountMyShare] > 0)
        self.btnPayNow.enabled = true;
    else
        self.btnPayNow.enabled = false;
}

- (void)openGroupsChanged
{
    // Don't care
}

- (NSUInteger) payingForCount
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if (appDelegate.globalObjectHolder.inStoreOrderDetails.paymentType == [InStoreOrderDetails PAYMENT_TYPE_PAYINFULL])
        return 1;
    else
    {
        int payingForCount = 0;
        for (GTLStoreendpointStoreTableGroupMember *member in appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.members)
        {
            if (member.payingUserId.longLongValue == appDelegate.globalObjectHolder.currentUser.identifier.longLongValue)
                payingForCount++;
        }
        return payingForCount;
    }
}

- (NSUInteger) groupCount
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if (appDelegate.globalObjectHolder.inStoreOrderDetails.paymentType == [InStoreOrderDetails PAYMENT_TYPE_PAYINFULL])
        return 1;
    else
        return appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.members.count;
}

- (void) updatePaymentValues
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if (appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order == nil || [self groupCount] == 0)
        return;
    self.txtFinalAmount.text = [UtilCalls rawAmountToString:[NSNumber numberWithDouble:[self finalTotal]]];
    self.txtSubTotal.text = [UtilCalls rawAmountToString:[NSNumber numberWithDouble:([self subTotalNoDiscountMyShare] - [self discount])]];
    self.txtTip.text = [UtilCalls rawAmountToString:[NSNumber numberWithDouble:[self gratuity]]];
    self.txtTax.text = [UtilCalls rawAmountToString:[NSNumber numberWithDouble:[self taxAmount]]];
    self.txtTipLabel.text = [NSString stringWithFormat:@"Tip (%d%%):", (int)(self.tipSlider.value)];
    
    GTLStoreendpointStoreTableGroupMember *memberMe = appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.memberMe;
    memberMe.finalTotal = [NSNumber numberWithInt:([self finalTotal]*100)];
    memberMe.subtotal = [NSNumber numberWithInt:([self subTotalNoDiscountMyShare] - [self discount])*100];
    memberMe.tip = [NSNumber numberWithInt:([self gratuity]*100)];
    memberMe.tax = [NSNumber numberWithInt:([self taxAmount]*100)];
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

- (double)subTotalNoDiscount
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    double subTotalNoDiscount = 0;
    for (OrderItemSummaryFromPOS *item in self.finalItems)
        subTotalNoDiscount += item.price;
    subTotalNoDiscount = subTotalNoDiscount - appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order.alreadyPaidSubtotal.doubleValue/100;
    return subTotalNoDiscount;
}

- (double)subTotalNoDiscountMyShare
{
    double subTotalNoDiscountMyShare = 0;
    if ([self groupCount] == 0)
        subTotalNoDiscountMyShare = 0;
    else
    {
        NSUInteger payingForCount = [self payingForCount];
        NSUInteger groupCount = [self groupCount];
        subTotalNoDiscountMyShare = [self subTotalNoDiscount]*payingForCount/groupCount;
    }
    return subTotalNoDiscountMyShare;
}

- (double)discount
{
    if ([self groupCount] == 0)
        return 0;
    else
        return [self discountAmount]*[self payingForCount]/[self groupCount];
}

- (double)discountAmount
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLStoreendpointStoreDiscount *discount = appDelegate.globalObjectHolder.inStoreOrderDetails.selectedDiscount;
    if (discount == nil)
        return 0;
    if (discount.percentOrAmount.boolValue == true)
        return ([self subTotalNoDiscount]*discount.value.intValue/100);
    else
        return discount.value.intValue/100;
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
    
    if ([self finalTotal] == 0)
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
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Please Wait";
    hud.hidden = NO;
    
    [self finishPayForMember];
}

- (void)finishPayForMember
{
    [self.timer invalidate];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    GTLStoreendpointSplitOrderArguments *orderArguments = [[GTLStoreendpointSplitOrderArguments alloc]init];
    NSMutableArray *members = [[NSMutableArray alloc]init];
    for (GTLStoreendpointStoreTableGroupMember *member in appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.members)
    {
        if (member.payingUserId.longLongValue == appDelegate.globalObjectHolder.currentUser.identifier.longLongValue)
        {
            if (member.identifier.longLongValue != appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.memberMe.identifier.longLongValue)
                 [members addObject:member];
        }
    }
    
    orderArguments.memberMe = appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.memberMe;
    orderArguments.storeTableGroup = appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.storeTableGroup;
    orderArguments.order = appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order;
    orderArguments.paidMembers = members;
    orderArguments.paymentType = [NSNumber numberWithInt:appDelegate.globalObjectHolder.inStoreOrderDetails.paymentType];
    orderArguments.gratuityPercent = [NSNumber numberWithInt:self.tipSlider.value];
    orderArguments.taxPercent = [NSNumber numberWithInt:appDelegate.globalObjectHolder.inStoreOrderDetails.selectedStore.taxPercent.intValue];
    
    if (self.stripePay.applePayEnabled && self.stripePay.token != nil)
        orderArguments.token = self.stripePay.token.tokenId;
    else
    {
        orderArguments.cardid = appDelegate.globalObjectHolder.defaultUserCard.cardId;
        orderArguments.customerId = appDelegate.globalObjectHolder.defaultUserCard.providerCustomerId;
    }
    
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
             MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
             hud.hidden = YES;
             if(!error)
             {
                 [UtilCalls handleClosedOrderFor:weakSelf SegueTo:@"segueUnwindMemberPayToStoreList"];
             }else{
                 NSLog(@"queryForPayForMemberWithObject Error:%@",[error userInfo][@"error"]);
                 [self startTimer];
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
