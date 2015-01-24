//
//  MainReviewViewController.m
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 1/23/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "MainReviewViewController.h"
#import "ReviewItemsTableViewController.h"
#import "ReviewSliderView.h"
#import "AppDelegate.h"
#import "UtilCalls.h"
#import "MBProgressHUD.h"


@interface MainReviewViewController()
@property (weak, nonatomic) IBOutlet ReviewSliderView *foodReviewSlider;
@property (weak, nonatomic) IBOutlet ReviewSliderView *serviceReviewSlider;
@property (weak, nonatomic) IBOutlet UITextView *txtReview;
@property (strong, nonatomic) GTLStoreendpointOrderReviewAndItemReviews *reviewAndItems;
@end

@implementation MainReviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.selectedOrder == nil)
        return;
    [self getOrderReview];
    [[self.txtReview layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[self.txtReview layer] setBorderWidth:2.3];
    [[self.txtReview layer] setCornerRadius:15];
}
- (void) getOrderReview
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Please Wait";
    hud.hidden = NO;
    if (self)
    {
        __weak __typeof(self) weakSelf = self;
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
        GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForGetReviewForCurrentUserAndOrderWithOrderId:self.selectedOrder.identifier.longValue];
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
        dic[USER_AUTH_TOKEN_HEADER_NAME]=[UtilCalls getAuthTokenForCurrentUser];
        
        [query setAdditionalHTTPHeaders:dic];
        
        [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLStoreendpointOrderReviewAndItemReviews *object,NSError *error)
         {
             if(!error)
             {
                 weakSelf.reviewAndItems = object;
                 self.foodReviewSlider.value = self.reviewAndItems.orderReview.foodLike.floatValue/100;
                 self.serviceReviewSlider.value = self.reviewAndItems.orderReview.serviceLike.floatValue/100;
                 self.txtReview.text = self.reviewAndItems.orderReview.comments;
             }else{
                 NSLog(@"getOrderReview Error:%@",[error userInfo]);
             }
             hud.hidden = YES;
         }];
    }

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
