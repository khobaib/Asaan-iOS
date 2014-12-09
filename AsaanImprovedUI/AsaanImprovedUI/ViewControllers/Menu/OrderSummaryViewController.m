//
//  OrderSummaryViewController.m
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 12/7/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "OrderSummaryViewController.h"

@interface OrderSummaryViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation OrderSummaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)addToOrder:(id)sender {
}
- (IBAction)removeFromOrder:(id)sender {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)placeOrder:(id)sender {
}
- (IBAction)cancelOrder:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
