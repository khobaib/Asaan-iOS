//
//  DeliveryOrCarryoutViewController.m
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 12/5/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "DeliveryOrCarryoutViewController.h"
#import "SelectAddressTableViewController.h"
#import "AddAddressTableViewController.h"
#import "SelectPaymentTableViewController.h"
#import "UIColor+AsaanGoldColor.h"
#import "UIColor+AsaanBackgroundColor.h"

@interface DeliveryOrCarryoutViewController ()
@property (weak, nonatomic) IBOutlet UILabel *txtCarryout;
@property (weak, nonatomic) IBOutlet UILabel *txtDelivery;
@end

@implementation DeliveryOrCarryoutViewController
@synthesize selectedStore = _selectedStore;

+ (int) ORDERTYPE_CARRYOUT { return 0;}
+ (int) ORDERTYPE_DELIVERY { return 1;}


- (void)viewDidLoad {
    [super viewDidLoad];
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
    self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor : [UIColor goldColor]};
    
    if (self.selectedStore.providesDelivery.boolValue == NO)
    {
        NSDictionary* attributes = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
        NSString *strMsg = [NSString stringWithFormat:@"Delivery: %@ does not provide delivery", self.selectedStore.name];
        NSAttributedString* attributedString = [[NSAttributedString alloc] initWithString:strMsg attributes:attributes];
        
        self.txtDelivery.attributedText = attributedString;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark === UITableViewDelegate ===
#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        self.orderType = [DeliveryOrCarryoutViewController ORDERTYPE_CARRYOUT];
        [self performSegueWithIdentifier:@"segueDeliveryPayment" sender:self];
    }
    else
    {
        if (self.selectedStore.providesDelivery.boolValue == NO)
            return;

        self.orderType = [DeliveryOrCarryoutViewController ORDERTYPE_DELIVERY];
        [self performSegueWithIdentifier:@"segueDeliveryAddress" sender:self];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    // Get reference to the destination view controller
    if ([[segue identifier] isEqualToString:@"segueDeliveryAddress"])
    {
        SelectAddressTableViewController *controller = [segue destinationViewController];
        [controller setSelectedStore:_selectedStore];
        [controller setOrderType:_orderType];
    }
    else if ([[segue identifier] isEqualToString:@"segueDeliveryPayment"])
    {
        SelectPaymentTableViewController *controller = [segue destinationViewController];
        [controller setSelectedStore:_selectedStore];
        [controller setOrderType:_orderType];
    }
}

@end
