//
//  OrderDiscountViewController.m
//  Savoir
//
//  Created by NSARAIYA on 1/18/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "OrderDiscountViewController.h"
#import "UIColor+SavoirGoldColor.h"
#import "UIColor+SavoirBackgroundColor.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "GTLStoreendpoint.h"
#import "InlineCalls.h"
#import "UtilCalls.h"

@interface OrderDiscountViewController ()

@property (weak, nonatomic) IBOutlet UITextField *txtDiscountCode;
@property (strong, nonatomic) GTLStoreendpointStoreDiscountCollection *discounts;
- (void) loadStoreDiscountsFromServer;
@end

@implementation OrderDiscountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadStoreDiscountsFromServer];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barTintColor = [UIColor asaanBackgroundColor];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    // Prevent keyboard from showing by default
    [self.txtDiscountCode endEditing:YES];
//    UIColor *color = [UIColor darkTextColor];
//    self.txtDiscountCode.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter Discount Code" attributes:@{NSForegroundColorAttributeName: color}];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)txtDiscountCodeEndOnExit:(UITextField *)sender forEvent:(UIEvent *)event {
    if (IsEmpty(self.txtDiscountCode.text) == true)
        return;
    
    NSString *notFoundResponse = [NSString stringWithFormat:@"%@ - No discount with code:%@ found", self.txtDiscountCode.text, self.txtDiscountCode.text];
    
    if (self.discounts == nil || self.discounts.items.count == 0)
    {
        self.txtDiscountCode.text = notFoundResponse;
        return;
    }

    for (GTLStoreendpointStoreDiscount *discount in self.discounts)
    {
        if (discount.code != nil && [discount.code caseInsensitiveCompare:self.txtDiscountCode.text] == NSOrderedSame) {
            NSString *foundResponse = [NSString stringWithFormat:@"%@ - %@", self.txtDiscountCode.text, discount.title];
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
            appDelegate.globalObjectHolder.orderInProgress.selectedDiscount = discount;
            self.txtDiscountCode.text = foundResponse;
            return;
        }
    }
}

- (void) loadStoreDiscountsFromServer
{
    __weak __typeof(self) weakSelf = self;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
    GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForGetStoreDiscountsWithStoreId:appDelegate.globalObjectHolder.orderInProgress.selectedStore.identifier.longLongValue];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    dic[USER_AUTH_TOKEN_HEADER_NAME] = [UtilCalls getAuthTokenForCurrentUser];
    [query setAdditionalHTTPHeaders:dic];
    [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error)
     {
         if (!error)
             weakSelf.discounts = object;
         else
             NSLog(@"Savoir Server Call Failed: getUserAddresses - error:%@", error.userInfo);
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
