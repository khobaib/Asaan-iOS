//
//  PayForOnlineOrderViewController.m
//  Savoir
//
//  Created by Nirav Saraiya on 5/1/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "PayForOnlineOrderViewController.h"
#import "AppDelegate.h"
#import "UtilCalls.h"
#import "MBProgressHUD.h"
#import "InlineCalls.h"
#import "Extension.h"
#import "OrderItemSummaryFromPOS.h"
#import "RXMLElement.h"
#import "OrderedDictionary.h"
#import "StripePay.h"
#import "GTLStoreendpointSplitOrderArguments.h"
#import "SelectPaymentTableViewController.h"
#import "XMLPOSOrder.h"
#import "OnlineOrderSelectedMenuItem.h"
#import "OrderTypeTableViewController.h"
#import "UIAlertView+Blocks.h"
#import "HTMLFaxOrder.h"

@interface PayForOnlineOrderViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *tipSegmentController;
@property (weak, nonatomic) IBOutlet UISlider *tipSlider;
@property (weak, nonatomic) IBOutlet UILabel *txtSubTotal;
@property (weak, nonatomic) IBOutlet UILabel *txtTip;
@property (weak, nonatomic) IBOutlet UILabel *txtTax;
@property (weak, nonatomic) IBOutlet UILabel *txtFinalAmount;
@property (weak, nonatomic) IBOutlet UILabel *txtTipLabel;
@property (weak, nonatomic) IBOutlet UIButton *btnPayNow;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *finalItems;

@property (strong, nonatomic) StripePay *stripePay;

@end

@implementation PayForOnlineOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.stripePay = [[StripePay alloc]init];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    self.tipSlider.value = appDelegate.globalObjectHolder.orderInProgress.tipPercent;
    
    [self tipSliderValueChanged:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    appDelegate.topViewController = self;
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if (appDelegate.globalObjectHolder.defaultUserCard == nil)
    {
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = @"No cards have been added. Please add a new card.";
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        [messageLabel sizeToFit];
        
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    else
    {
        self.tableView.backgroundView = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PaymentCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    UIImageView *imgCardType=(UIImageView *)[cell viewWithTag:501];
    UILabel *txtCardDetails=(UILabel *)[cell viewWithTag:502];

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if (appDelegate.globalObjectHolder.defaultUserCard != nil)
    {
        imgCardType.image = [UIImage imageNamed:appDelegate.globalObjectHolder.defaultUserCard.type];
        txtCardDetails.text = [NSString stringWithFormat:@"%@            %ld/%ld", appDelegate.globalObjectHolder.defaultUserCard.last4, appDelegate.globalObjectHolder.defaultUserCard.expMonth.longValue, appDelegate.globalObjectHolder.defaultUserCard.expYear.longValue];
    }
    else
    {
        imgCardType.image = nil;
        txtCardDetails.text = @"No card available. Please add a card to proceed.";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"seguePayForOnlineToSelectPayment" sender:self];
}

#pragma mark - Internal Calls

- (double)gratuity
{
    return self.subTotalNoDiscount * self.tipSlider.value/100;
}

- (double)taxAmount
{
    double tax = self.selectedStore.taxPercent.longValue/10000.0;
    return (self.subTotal + self.deliveryFee + [self gratuity])*tax;
}

- (double)finalTotal
{
    return self.subTotal + [self gratuity] + self.deliveryFee + [self taxAmount];
}

- (void) updatePaymentValues
{
    self.txtSubTotal.text = [UtilCalls rawAmountToString:[NSNumber numberWithDouble:self.subTotal]];
    self.txtTip.text = [UtilCalls rawAmountToString:[NSNumber numberWithDouble:[self gratuity]]];
    self.txtFinalAmount.text = [UtilCalls rawAmountToString:[NSNumber numberWithDouble:[self finalTotal]]];
    self.txtTax.text = [UtilCalls rawAmountToString:[NSNumber numberWithDouble:[self taxAmount]]];
    self.txtTipLabel.text = [NSString stringWithFormat:@"Tip (%d%%):", (int)(self.tipSlider.value)];
}

- (NSString *)orderDateString
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSDate *currentTime = [NSDate date];
    NSDate *newTime = appDelegate.globalObjectHolder.orderInProgress.orderTime;
    
    NSDate *minOrderTime = [[NSDate alloc] initWithTimeInterval:3600
                                                      sinceDate:currentTime];
    NSDate *orderTime = [newTime laterDate:minOrderTime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    return [dateFormatter stringFromDate: orderTime];
}

#pragma mark - Actions

- (IBAction)tipSegmentControllerValueChanged:(id)sender
{
    if (self.tipSegmentController.selectedSegmentIndex == 0)
        self.tipSlider.value = 5;
    else if (self.tipSegmentController.selectedSegmentIndex == 1)
        self.tipSlider.value = 10;
    else if (self.tipSegmentController.selectedSegmentIndex == 2)
        self.tipSlider.value = 15;
    
    [self updatePaymentValues];
}

- (IBAction)tipSliderValueChanged:(id)sender
{
    if (self.tipSlider.value == 5)
        self.tipSegmentController.selectedSegmentIndex = 0;
    else if (self.tipSlider.value == 10)
        self.tipSegmentController.selectedSegmentIndex = 1;
    if (self.tipSlider.value == 15)
        self.tipSegmentController.selectedSegmentIndex = 2;
    else
        self.tipSegmentController.selectedSegmentIndex = 3;
    
    [self updatePaymentValues];
}

- (IBAction)payNowClicked:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    if (self.subTotal == 0)
        return;
    
    GTLStoreendpointStoreOrder *order = [[GTLStoreendpointStoreOrder alloc]init];
    
    order.guestCount = [NSNumber numberWithInt:appDelegate.globalObjectHolder.orderInProgress.partySize];  // intValue
    order.orderMode = [NSNumber numberWithInt:appDelegate.globalObjectHolder.orderInProgress.orderType];  // intValue
    order.storeId = self.selectedStore.identifier;  // longLongValue
    order.storeName = self.selectedStore.name;
    order.subTotal = [UtilCalls doubleAmountToLong:[self subTotal]];
    order.deliveryFee = [UtilCalls doubleAmountToLong:[self deliveryFee]];
    
    if ([self discountAmount] > 0)
    {
        order.discount = [UtilCalls doubleAmountToLong:[self discountAmount]];
        order.discountDescription = appDelegate.globalObjectHolder.orderInProgress.selectedDiscount.title;
    }
    
    GTLStoreendpointPlaceOrderArguments *orderArguments = [[GTLStoreendpointPlaceOrderArguments alloc]init];
    orderArguments.order = order;
    
    orderArguments.order.serviceCharge = [UtilCalls doubleAmountToLong:[self gratuity]];
    orderArguments.order.tax = [UtilCalls doubleAmountToLong:[self taxAmount]];
    long long finalTotal = [UtilCalls doubleAmountToLong:[self finalTotal]].longLongValue;
    orderArguments.order.finalTotal = [NSNumber numberWithLongLong:finalTotal];
    
    NSString *strOrder = nil;
    orderArguments.order.orderHTML = [HTMLFaxOrder buildHTMLOrder:appDelegate.globalObjectHolder.orderInProgress gratuity:[self gratuity] discountTitle:self.discountTitle discountAmount:self.discountAmount subTotal:self.subTotal deliveryFee:self.deliveryFee taxAmount:[self taxAmount] finalAmount:[self finalTotal] orderEstTime:[self orderDateString]];
    
    if (self.selectedStore.providesPosIntegration.boolValue == NO)
    {
        strOrder = orderArguments.order.orderHTML;
        orderArguments.order.orderDetails = [XMLPOSOrder buildPOSResponseXML:appDelegate.globalObjectHolder.orderInProgress checkId:0 gratuity:[self gratuity] subTotal:self.subTotal deliveryFee:self.deliveryFee taxAmount:[self taxAmount] finalAmount:[self finalTotal] guestCount:orderArguments.order.guestCount.intValue tableNumber:0];
    }
    else
        strOrder = [XMLPOSOrder buildPOSOrder:appDelegate.globalObjectHolder.orderInProgress gratuity:[self gratuity]];
    
    orderArguments.strOrder = strOrder;
    
    if ([StripePay applePayEnabled])
    {
        if (self.stripePay.token == nil)
        {
            NSString *amountStr = [UtilCalls doubleAmountToString:[NSNumber numberWithDouble:[self finalTotal]]];
            NSDecimalNumber *finalAmount = [NSDecimalNumber decimalNumberWithString:amountStr];
            [self.stripePay beginApplePay:self Title:self.selectedStore.name Label:@"Order" AndAmount:finalAmount];
            return;
        }
    }
    else
    {
        if (appDelegate.globalObjectHolder.defaultUserCard == nil)
        {
            [self performSegueWithIdentifier:@"seguePayForOnlineToSelectPayment" sender:self];
            return;
        }
    }
    
    if ([StripePay applePayEnabled] && self.stripePay.token != nil)
        orderArguments.token = self.stripePay.token.tokenId;
    else
    {
        orderArguments.userId = appDelegate.globalObjectHolder.defaultUserCard.userId;  // longLongValue
        orderArguments.cardid = appDelegate.globalObjectHolder.defaultUserCard.cardId;
        orderArguments.customerId = appDelegate.globalObjectHolder.defaultUserCard.providerCustomerId;
    }
    
    
    if ([UtilCalls canStore:self.selectedStore fulfillOrderAt:appDelegate.globalObjectHolder.orderInProgress.orderTime] == NO)
    {
        NSString *msg = [NSString stringWithFormat:@"%@ cannot accept any online orders at this time.", self.selectedStore.name];
        [[[UIAlertView alloc]initWithTitle:@"Online Order Failure" message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        return;
    }
    
    __weak __typeof(self) weakSelf = self;
    
    GTLQueryStoreendpoint *query=[GTLQueryStoreendpoint queryForPlaceOrderWithObject:orderArguments];
    
    NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
    dic[USER_AUTH_TOKEN_HEADER_NAME]=[UtilCalls getAuthTokenForCurrentUser];
    
    [query setAdditionalHTTPHeaders:dic];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
    [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,GTLStoreendpointStoreOrder *object,NSError *error)
     {
         [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
         
         if(error == nil && object.identifier != nil && object.identifier.longLongValue != 0)
         {
             NSString *title = [NSString stringWithFormat:@"Your Order - %@", self.selectedStore.name];
             NSString *msg = [NSString stringWithFormat:@"Thank you - your order has been placed. If you need to make changes please call %@ immediately at %@.", weakSelf.selectedStore.name, weakSelf.selectedStore.phone];
             [appDelegate.globalObjectHolder removeOrderInProgress];
             UIAlertView *alert=[[UIAlertView alloc]initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
             [alert show];
             NotificationUtils *notificationUtils = [[NotificationUtils alloc]init];
             [notificationUtils scheduleNotificationWithOrder:object];
             if (self.revealViewController != nil)
                 [weakSelf performSegueWithIdentifier:@"SWOnlineOrderPayToStoreList" sender:weakSelf];
             else
                 [weakSelf performSegueWithIdentifier:@"segueUnwindMemberPayToStoreList" sender:weakSelf];
         }
         else
         {
             NSLog(@"%@",[error userInfo][@"error"]);
             NSString *title = @"Something went wrong";
             NSString *msg = [NSString stringWithFormat:@"We were unable to reach %@ and place your order. We're really sorry. Please call %@ directly at %@ to place your order.", weakSelf.selectedStore.name, weakSelf.selectedStore.name, weakSelf.selectedStore.phone];
             [UtilCalls handleGAEServerError:error Message:msg Title:title Silent:false];
         }
     }];
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
