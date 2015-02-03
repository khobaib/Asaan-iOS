//
//  MainReviewViewController.m
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 1/23/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "MainReviewViewController.h"
#import "ReviewItemsTableViewController.h"
#import "AppDelegate.h"
#import "UtilCalls.h"
#import "NotificationUtils.h"


@interface MainReviewViewController()
@property (weak, nonatomic) IBOutlet UISlider *foodReviewSlider;
@property (weak, nonatomic) IBOutlet UISlider *serviceReviewSlider;
@property (weak, nonatomic) IBOutlet UITextView *txtReview;
@property (weak, nonatomic) IBOutlet UIScrollView *reviewScrollView;

- (void)backButtonPressed;

@end

@implementation MainReviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [super setBaseScrollView:self.reviewScrollView];
    if (self.selectedOrder == nil)
        return;

    [[self.txtReview layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[self.txtReview layer] setBorderWidth:2.3];
    [[self.txtReview layer] setCornerRadius:15];
    
    self.txtReview.text = self.reviewAndItems.orderReview.comments;
    if (self.reviewAndItems == nil || self.reviewAndItems.orderReview.foodLike.longValue == 0)
        self.foodReviewSlider.value = 1.5;
    else
        self.foodReviewSlider.value = self.reviewAndItems.orderReview.foodLike.floatValue/100;
    if (self.reviewAndItems == nil || self.reviewAndItems.orderReview.serviceLike.longValue == 0)
        self.serviceReviewSlider.value = 1.5;
    else
        self.serviceReviewSlider.value = self.reviewAndItems.orderReview.serviceLike.floatValue/100;
    
    self.navigationItem.title = [NSString stringWithFormat:@"How was %@?", self.selectedOrder.storeName];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([UtilCalls orderHasAlreadyBeenReviewed:self.reviewAndItems] == true)
        [self backButtonPressed];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];
    self.navigationItem.leftBarButtonItem = backButton;
    // Prevent keyboard from showing by default
    [self.view endEditing:YES];
    NotificationUtils *notificationUtils = [[NotificationUtils alloc]init];
    [notificationUtils cancelNotificationWithOrder:self.selectedOrder.identifier];
//    [UtilCalls getSlidingMenuBarButtonSetupWith:self];
}

- (void)backButtonPressed
{
    // write your code to prepare popview
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)foodReviewSliderValueChanged:(id)sender
{
}
- (IBAction)serviceReviewSliderValueChanged:(id)sender
{
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"segueReviewMainToReviewItems"])
    {
        self.reviewAndItems.orderReview.foodLike = [NSNumber numberWithFloat:self.foodReviewSlider.value*100];
        self.reviewAndItems.orderReview.serviceLike = [NSNumber numberWithFloat:self.serviceReviewSlider.value*100];
        self.reviewAndItems.orderReview.comments = self.txtReview.text;
        [self saveOrderReview];
        ReviewItemsTableViewController *controller = [segue destinationViewController];
        [controller setSelectedOrder:self.selectedOrder];
        controller.reviewAndItems = self.reviewAndItems;
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

    [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error)
     {
         if (error)
             NSLog(@"saveOrderReview Error:%@",[error userInfo]);
     }];
}

@end
