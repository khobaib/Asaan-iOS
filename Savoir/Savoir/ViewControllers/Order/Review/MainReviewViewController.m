//
//  MainReviewViewController.m
//  Savoir
//
//  Created by Nirav Saraiya on 1/23/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "MainReviewViewController.h"
#import "ReviewItemsTableViewController.h"
#import "AppDelegate.h"
#import "UtilCalls.h"
#import "NotificationUtils.h"
#import "InlineCalls.h"
#import "SZTextView.h"


@interface MainReviewViewController()
@property (weak, nonatomic) IBOutlet UISlider *foodReviewSlider;
@property (weak, nonatomic) IBOutlet UISlider *serviceReviewSlider;
@property (weak, nonatomic) IBOutlet SZTextView *txtReview;
@property (weak, nonatomic) IBOutlet UIScrollView *reviewScrollView;
@property (weak, nonatomic) IBOutlet UIView *headerView;

@property (nonatomic) Boolean foodValueChanged;
@property (nonatomic) Boolean serviceValueChanged;

- (void)backButtonPressed;

@end

@implementation MainReviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [super setBaseScrollView:self.reviewScrollView];
    
    if (self.selectedOrder == nil)
        return;
    NSString *strTitle = [NSString stringWithFormat:@"Tell us about your experience at %@", self.selectedOrder.storeName];
    [UtilCalls setupHeaderView:self.headerView WithTitle:strTitle AndSubTitle:nil];

    [[self.txtReview layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[self.txtReview layer] setBorderWidth:2.3];
    [[self.txtReview layer] setCornerRadius:15];
    
//    self.txtReview.placeholder = @"Tell us what made your experience memorable. Amazing food, excellent service or perfect ambiance? Tell us more ...";
    UIColor *color = [UIColor grayColor];
    self.txtReview.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Tell us what made your experience memorable. Amazing food, excellent service or perfect ambiance? Tell us more ..." attributes:@{NSForegroundColorAttributeName: color}];
    
    self.txtReview.text = self.reviewAndItems.orderReview.comments;
    if (self.reviewAndItems == nil || self.reviewAndItems.orderReview.foodLike.longLongValue == 0)
        self.foodReviewSlider.value = 1.5;
    else
        self.foodReviewSlider.value = self.reviewAndItems.orderReview.foodLike.floatValue/100;
    if (self.reviewAndItems == nil || self.reviewAndItems.orderReview.serviceLike.longLongValue == 0)
        self.serviceReviewSlider.value = 1.5;
    else
        self.serviceReviewSlider.value = self.reviewAndItems.orderReview.serviceLike.floatValue/100;
    
//    self.navigationItem.title = [NSString stringWithFormat:@"How was %@?", self.selectedOrder.storeName];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.foodValueChanged = false;
    self.serviceValueChanged = false;
    
    if ([UtilCalls orderHasAlreadyBeenReviewed:self.reviewAndItems] == true)
        [self backButtonPressed];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    if (self.presentedFromNotification == true)
    {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];
        self.navigationItem.leftBarButtonItem = backButton;
    }
    // Prevent keyboard from showing by default
    [self.view endEditing:YES];
    NotificationUtils *notificationUtils = [[NotificationUtils alloc]init];
    [notificationUtils cancelNotificationWithOrder:self.selectedOrder.identifier];
//    [UtilCalls getSlidingMenuBarButtonSetupWith:self];
}

- (void)backButtonPressed
{
    if (self.presentedFromNotification == true)
        [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)foodReviewSliderValueChanged:(id)sender
{
    self.foodValueChanged = true;
}
- (IBAction)serviceReviewSliderValueChanged:(id)sender
{
    self.serviceValueChanged = true;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"segueReviewMainToReviewItems"])
    {
        if (self.foodValueChanged == true || self.serviceValueChanged == true || IsEmpty(self.txtReview.text) == false)
        {
            if (self.foodValueChanged == true) self.reviewAndItems.orderReview.foodLike = [NSNumber numberWithFloat:self.foodReviewSlider.value*100];
            if (self.serviceValueChanged == true) self.reviewAndItems.orderReview.serviceLike = [NSNumber numberWithFloat:self.serviceReviewSlider.value*100];
            self.reviewAndItems.orderReview.comments = self.txtReview.text;
            [self saveOrderReview];
        }
        ReviewItemsTableViewController *controller = [segue destinationViewController];
        [controller setSelectedOrder:self.selectedOrder];
        controller.reviewAndItems = self.reviewAndItems;
        controller.presentedFromNotification = self.presentedFromNotification;
    }
}

- (void) saveOrderReview
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
    GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForSaveStoreOrderReviewWithObject:self.reviewAndItems.orderReview];
    NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
    dic[USER_AUTH_TOKEN_HEADER_NAME]=[UtilCalls getAuthTokenForCurrentUser];
    
    [query setAdditionalHTTPHeaders:dic];

    [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLStoreendpointOrderReview *object, NSError *error)
     {
         if (error)
             NSLog(@"saveOrderReview Error:%@",[error userInfo]);
         else
             self.reviewAndItems.orderReview = object;
     }];
}

@end
