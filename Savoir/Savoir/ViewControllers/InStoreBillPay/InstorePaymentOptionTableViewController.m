//
//  InstorePaymentOptionTableViewController.m
//  Savoir
//
//  Created by Nirav Saraiya on 4/5/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "InstorePaymentOptionTableViewController.h"
#import "AppDelegate.h"

@interface InstorePaymentOptionTableViewController ()

@end

@implementation InstorePaymentOptionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if(indexPath.row == 0)
    {
        appDelegate.globalObjectHolder.inStoreOrderDetails.paymentType = [InStoreOrderDetails PAYMENT_TYPE_SPLITEVENLY];
        [self performSegueWithIdentifier:@"seguePaymentSplitEvenly" sender:self];
    }
    else if(indexPath.row == 1)
    {
        appDelegate.globalObjectHolder.inStoreOrderDetails.paymentType = [InStoreOrderDetails PAYMENT_TYPE_PAYINFULL];
        [self performSegueWithIdentifier:@"seguePayEntireAmount" sender:self];
    }
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
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
